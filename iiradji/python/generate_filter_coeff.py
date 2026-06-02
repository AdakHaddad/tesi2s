from scipy import signal
import numpy as np

import os

from filter_config import FS
from filter_config import Q_FORMAT
from filter_config import filters

# CONFIG
# FS = 10000
# Q_FORMAT = 14
SCALE = 2**Q_FORMAT

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_FILE = os.path.join(BASE_DIR, "..", "rtl", "filter_coeff.v")

# FILTER LIST
# filters = [

#     # LPF
#     {
#         "sw": 0,
#         "type": "low",
#         "fc": 500,
#         "order": 4
#     },

#     {
#         "sw": 1,
#         "type": "low",
#         "fc": 800,
#         "order": 4
#     },

#     {
#         "sw": 2,
#         "type": "low",
#         "fc": 1000,
#         "order": 4
#     },

#     # HPF
#     {
#         "sw": 3,
#         "type": "high",
#         "fc": 500,
#         "order": 4
#     },

#     {
#         "sw": 4,
#         "type": "high",
#         "fc": 800,
#         "order": 4
#     },

#     {
#         "sw": 5,
#         "type": "high",
#         "fc": 1000,
#         "order": 4
#     },

#     # BPF
#     {
#         "sw": 6,
#         "type": "bandpass",
#         "fc": [500,1000],
#         "order": 2
#     },

#     # BSF
#     {
#         "sw": 7,
#         "type": "bandstop",
#         "fc": [500,1000],
#         "order": 2
#     }
# ]

def q14(x):
    raw = x * SCALE
    q = int(np.round(raw))

    if q > 32767:
        print(f"[WARN] coefficient clipped: {raw} -> 32767")
        q = 32767

    elif q < -32768:
        print(f"[WARN] coefficient clipped: {raw} -> -32768")
        q = -32768

    return q
    # return int(np.round(x * SCALE))

def verilog_signed(val):
    if val < 0:
        return f"-16'sd{abs(val)}"
    else:
        return f"16'sd{val}"

def generate_comment(ftype, fc):
    type_map = {
        "low": "LP",
        "high": "HP",
        "bandpass": "BP",
        "bandstop": "BS"
    }

    label = type_map[ftype]

    if isinstance(fc, int):
        return f"fc = {fc} Hz {label}"

    elif isinstance(fc, list):
        return f"fc = {fc[0]}-{fc[1]} Hz {label}"

# GENERATE SOS
filter_sos = []
max_stage = 0

for f in filters:
    sos = signal.butter(
        f["order"],
        f["fc"],
        btype=f["type"],
        fs=FS,
        output='sos'
    )

    n_stage = len(sos)

    if n_stage > max_stage:
        max_stage = n_stage

    filter_sos.append({
        "config": f,
        "sos": sos,
        "n_stage": n_stage
    })

# GENERATE REGISTER DECLARATION
reg_text = ""

for i in range(max_stage):
    idx = i + 1
    reg_text += f"reg signed [15:0] b0_{idx}, b1_{idx}, b2_{idx}, a1_{idx}, a2_{idx};\n"

# GENERATE STAGE WIRES
wire_text = ""

for i in range(max_stage - 1):
    idx = i + 1
    wire_text += f"wire signed [15:0] stage{idx}_out;\n"

# GENERATE CASE STATEMENTS

case_text = ""

for item in filter_sos:
    cfg = item["config"]
    sos = item["sos"]
    n_stage = item["n_stage"]

    sw = cfg["sw"]
    comment = generate_comment(cfg["type"], cfg["fc"])

    case_text += f"      3'd{sw}: begin\n"
    case_text += f"        // {comment}\n"

    # ACTIVE STAGES
    for i in range(n_stage):
        idx = i + 1

        b0, b1, b2, a0, a1, a2 = sos[i]

        b0 = q14(b0)
        b1 = q14(b1)
        b2 = q14(b2)

        a1 = q14(a1)
        a2 = q14(a2)

        case_text += f"        b0_{idx} <= {verilog_signed(b0)};\n"
        case_text += f"        b1_{idx} <= {verilog_signed(b1)};\n"
        case_text += f"        b2_{idx} <= {verilog_signed(b2)};\n"
        case_text += f"        a1_{idx} <= {verilog_signed(a1)};\n"
        case_text += f"        a2_{idx} <= {verilog_signed(a2)};\n"

        if i != max_stage - 1:
          case_text += "\n"

    # UNUSED STAGES -> BYPASS
    for i in range(n_stage, max_stage):
        idx = i + 1

        case_text += f"        b0_{idx} <= 16'sd16384;\n"
        case_text += f"        b1_{idx} <= 16'sd0;\n"
        case_text += f"        b2_{idx} <= 16'sd0;\n"
        case_text += f"        a1_{idx} <= 16'sd0;\n"
        case_text += f"        a2_{idx} <= 16'sd0;\n"

        if i != max_stage - 1:
          case_text += "\n"
    case_text += "      end\n\n"

# GENERATE BIQUAD INSTANCES
inst_text = ""

for i in range(max_stage):
    idx = i + 1

    # INPUT SOURCE
    if i == 0:
        x_source = "x_in"
    else:
        x_source = f"stage{i}_out"

    # OUTPUT DESTINATION
    if i == max_stage - 1:
        y_dest = "y_out"
    else:
        y_dest = f"stage{idx}_out"

    inst_text += f"""
filter_biquad stage{idx}(
    .b0(b0_{idx}),
    .b1(b1_{idx}),
    .b2(b2_{idx}),
    .a1(a1_{idx}),
    .a2(a2_{idx}),

    .clk(clk),
    .valid(valid),
    .x_in({x_source}),
    .y_out({y_dest})
);
"""

# GENERATE FULL VERILOG
verilog = f"""
`timescale 1ns / 1ps

module filter_coeff (
    input clk,
    input valid,
    input [2:0] sw,
    input signed [15:0] x_in,
    output signed [15:0] y_out
);

// COEFFICIENT REGISTERS
{reg_text}
// INTER-STAGE WIRES
{wire_text}
// COEFFICIENT SELECTOR
always @(posedge clk) begin
  if(valid) begin
    case(sw)
{case_text}"""

# DEFAULT CASE
verilog += "      default: begin\n"

for i in range(max_stage):

    idx = i + 1

    verilog += f"        b0_{idx} <= 16'sd16384;\n"
    verilog += f"        b1_{idx} <= 16'sd0;\n"
    verilog += f"        b2_{idx} <= 16'sd0;\n"
    verilog += f"        a1_{idx} <= 16'sd0;\n"
    verilog += f"        a2_{idx} <= 16'sd0;\n"

    # spasi antar stage
    if i != max_stage - 1:
        verilog += "\n"

verilog += """      end
    endcase
  end
end

// BIQUAD CASCADE"""
verilog += inst_text
verilog += """
endmodule
"""

# WRITE FILE
with open(OUTPUT_FILE, "w") as f:
    f.write(verilog.strip())

print(f"Generated: {OUTPUT_FILE}")
