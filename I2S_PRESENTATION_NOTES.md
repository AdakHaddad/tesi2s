# Thesis Presentation Master Guide: Custom I2S IP with Hardware DDS

---

## 0. Fundamentals: The Three-Wire Interface
**Question: "Explain the relationship between your three serial lines."**

*   **BCLK (Bit Clock)**: The heartbeat. For every 1 bit of data, BCLK pulses once. 
    *   *Calculation*: $Fs \times \text{Channels} \times \text{Bits per Channel}$. 
    *   For 48 kHz, 2 channels, 32 bits: $48000 \times 2 \times 32 = 3.072\text{ MHz}$.
*   **WS (Word Select / LRCLK)**: The "Who is speaking?" signal.
    *   **WS = 0**: Left Channel.
    *   **WS = 1**: Right Channel.
    *   The frequency of WS is exactly the Sample Rate ($Fs$).
*   **SD (Serial Data)**: The payload. Bits are shifted out on the **falling edge** of BCLK so the DAC can safely sample them on the **rising edge** (Setup/Hold time margin).

---

## 1. The I2S Clocking Architecture (The "Dual-Family" Strategy)
**Question: "Why did you use two different oscillators (22.579 MHz and 24.576 MHz)?"**

*   **The Problem**: Audio sample rates belong to two "families":
    *   **48k Family**: 48, 96, 192 kHz.
    *   **44.1k Family**: 44.1, 88.2, 176.4 kHz.
*   **The Solution**: To get an exact 48.000 kHz clock from a standard 100 MHz system clock, you'd need a complex fractional divider which introduces **jitter**. 
*   **Implementation**: By using external oscillators that are exact multiples ($512 \times F_s$), we ensure zero-jitter clocking. 
    *   $48,000 \times 512 = 24.576\text{ MHz}$
    *   $44,100 \times 512 = 22.579\text{ MHz}$
*   **The Switching**: We use a `BUFGMUX` (Global Clock Buffer Multiplexer) controlled by the `FS_FAMILY` bit. This allows glitch-free switching between the two clock families at runtime.

---

## 1b. The "Bit-Clock Ratio" Detail
**Question: "Why is your BCLK always 64 times the Fs?"**

*   **Logic**: Even if we only send 16-bit audio, the I2S standard usually allocates a 32-bit "slot" per channel ($32 + 32 = 64$ bits per frame).
*   **Reason**: This makes the hardware compatible with all word lengths (16, 24, 32 bit) without changing the clock frequency. The DAC simply ignores the trailing zeros if the word is shorter than the slot.

---

## 2. The Famous "1-Bit Delay" (Philips I2S Standard)
**Question: "Why does the data start one clock cycle AFTER the Word Select (WS) edge?"**

*   **The Standard**: The Philips I2S specification dictates that the MSB is transmitted one BCLK cycle after the WS transition.
*   **Reasoning**: This was designed in the 1980s to allow for simple hardware logic. The one-cycle delay gives the receiving DAC time to latch the WS state and prepare its internal shift registers before the first data bit (MSB) arrives.
*   **Implementation Note**: If you forget this bit, your audio will have a "bit-shift" error, resulting in significant noise (LSB interpreted as MSB).

---

## 2b. I2S vs. Left-Justified (LJ)
**Question: "What is the difference between I2S and Left-Justified format?"**

*   **I2S**: Data starts 1 clock after WS edge. WS is LOW for Left.
*   **Left-Justified**: Data starts *exactly* on the WS edge. WS is HIGH for Left.
*   **Why it matters**: If your FPGA is set to LJ but the DAC expects I2S, the audio will be 6dB quieter and have distorted polarity because every bit is shifted by one position.

---

## 3. Data Flow: From CPU to Serial Out
**Question: "How does a 32-bit integer in C become a sound wave?"**

1.  **AXI Write**: The MicroBlaze CPU writes a 32-bit value to `DATA_LEFT` (REG0).
2.  **CDC (Clock Domain Crossing)**: The data moves from the 100 MHz AXI clock domain to the ~24 MHz Audio clock domain. We use a **Write Counter & Synchronizer** to ensure the audio logic never reads "half-written" data.
3.  **Latching**: On the falling edge of WS, the core captures the values from the AXI registers into "Shadow Registers."
4.  **Serialization**: A state machine (the "Serialiser") shifts these bits out one by one, MSB first, synchronized to the `BCLK`.

---

## 3b. Clock Domain Crossing (CDC) Deep-Dive
**Question: "How do you prevent 'Data Tearing' when moving from 100MHz to 24MHz?"**

*   **The Risk**: If the CPU writes the Left sample, and the Audio logic reads *before* the Right sample is written, you get a "Frankenstein" stereo frame (Old Right + New Left).
*   **My Solution**: I implemented a **CDC Write-Counter Handshake**. 
    1. A 4-bit counter in the AXI domain increments on every write.
    2. A **Triple-Flip-Flop Synchronizer** moves this counter to the Audio domain.
    3. The Audio domain only latches new data when it detects the counter has changed. 
    4. This ensures "Atomic Updates"—both channels are updated together.

---

## 4. Data Types: Integers vs. Alternatives
**Question: "Why use Signed Integers? Could we use Floating Point?"**

*   **Current Choice**: **2's Complement Signed Integers**. This is the industry standard for PCM (Pulse Code Modulation) audio. 
    *   `0x7FFFFFFF` = Maximum Positive Volume.
    *   `0x00000000` = Zero (Silence).
    *   `0x80000000` = Maximum Negative Volume.
*   **Alternatives**:
    *   **Floating Point**: CPUs love float, but DACs do not. To use floats, the FPGA would need a "Float-to-Fixed" converter, which consumes massive resources (DSP slices).
    *   **Unsigned**: Requires a DC-offset ($V_{cc}/2$), which causes a "pop" sound when starting/stopping. Signed integers are safer.

---

## 5. Hardware DDS (Direct Digital Synthesis) implementation
**Question: "How did you implement the internal Signal Generator?"**

The DDS bypasses the AXI Data registers and generates samples internally using three components:

1.  **Phase Accumulator (32-bit)**: 
    *   Think of this as a "circular dial" with $2^{32}$ positions. 
    *   Every sample clock, we add a `Phase Increment` to it.
    *   $Phase\_Inc = \frac{Frequency \times 2^{32}}{Sample\_Rate}$.
2.  **Sine Look-Up Table (LUT)**: 
    *   We don't calculate $\sin(x)$ (too slow). We store one cycle of a sine wave in a 256-word memory.
    *   The top 8 bits of the Phase Accumulator act as the "address" for this memory.
3.  **Mode Switch**: 
    *   **Sine**: Address → LUT → Output.
    *   **Square**: Only looks at the MSB of the accumulator. If bit 31 is 1, output max positive; if 0, output max negative.

---

## 5b. DDS Math: The Phase Increment Calculation
**Question: "Show me the math for your frequency accuracy."**

*   **Formula**: $f_{out} = \frac{\Delta \text{Phase} \times Fs}{2^{32}}$
*   **Example**: To get 1000 Hz at 48 kHz:
    *   $\Delta \text{Phase} = \frac{1000 \times 2^{32}}{48000} \approx 89,478,485$
*   **Resolution**: With a 32-bit accumulator at 48 kHz, the frequency resolution is $\frac{48000}{2^{32}} \approx 0.000011\text{ Hz}$. This is far more precise than any analog oscillator.

---

## 6. Supervisor "Trap" Questions
*   **Q: "What happens if the FIFO overflows?"**
    *   **A**: "In this lightweight design, we don't use a FIFO. We use a **Shadow Register** approach. The CPU is responsible for updating the register before the next WS cycle. This minimizes latency for real-time applications."
*   **Q: "How do you handle metastability?"**
    *   **A**: "All control signals from the CPU are passed through a **Dual-Flip-Flop Synchronizer** before entering the audio clock domain. This ensures the I2S state machine never enters an undefined state."

---

## 7. Future Enhancements (The "Polish")
If asked what's next:
*   **DMA Integration**: To play music files without CPU intervention.
*   **Volume Control**: Digital scaling (multiplication) before serialization.
*   **Interpolation**: Upsampling 44.1k to 88.2k for smoother DAC filters.

---

## 8. Summary of Physical Constraints (The "Real World")
*   **Voltage Levels**: The PMOD I2S2 uses 3.3V LVCMOS.
*   **MCLK Necessity**: While I2S usually needs 3 wires, many modern DACs (like PCM5102A) can "recover" the clock from BCLK using an internal PLL. However, providing a dedicated MCLK (as I did) reduces jitter and improves audio quality.
*   **Logic Levels**: Data is shifted MSB-first. This is because the most significant bits carry the "energy" of the sound; if a transmission is interrupted, losing LSBs is less audible than losing MSBs.

---

## 9. Endianness: Little vs. Big (Bit vs. Byte)
**Question: "Is I2S Little-Endian or Big-Endian? How does it match your CPU?"**

*   **The Definition**: 
    *   **Big-Endian**: The "Big end" (Most Significant Byte/Bit) comes first.
    *   **Little-Endian**: The "Little end" (Least Significant Byte/Bit) comes first.
*   **I2S is Big-Endian (Bit-level)**: The I2S protocol *always* sends the MSB (Most Significant Bit) first. This is a bit-level "Big-Endian" behavior.
*   **The CPU (MicroBlaze RISC-V)**: Modern RISC-V and MicroBlaze are typically **Little-Endian**. This means in memory, the least significant byte is stored at the lowest address.
*   **The Interaction**: 
    *   When the CPU writes a 32-bit integer to the AXI register, the **AXI Interconnect** handles the byte-mapping. 
    *   In the FPGA hardware, we receive the 32-bit word. We don't care about "bytes"—we simply take `bit[31]` and send it first, then `bit[30]`, and so on.
*   **Why MSB First?**: In audio, the MSB carries the most "energy." If a signal is truncated (e.g., sending 24-bit data into a 16-bit DAC), losing the "Little" bits (LSBs) only reduces precision (adds minor noise), but losing the "Big" bits (MSBs) would completely destroy the waveform.

---

## 10. Advanced Examiner "Deep-Dives"
**These questions test if you understand the *consequences* of your design choices.**

### Q1: "Your DDS uses a 256-entry LUT. Doesn't that cause Harmonic Distortion?"
*   **The Answer**: "Yes, a 256-entry table introduces some quantization noise. However, because we use a **32-bit Phase Accumulator**, we are performing high-resolution phase-to-amplitude mapping. To further improve this, we could implement **Linear Interpolation** between LUT entries, which would significantly reduce the noise floor without needing a massive table."

### Q2: "Why did you use a software loop to stream audio instead of a DMA?"
*   **The Answer**: "For this thesis, the priority was **low-level control and diagnostic transparency**. A CPU-driven loop allowed me to implement real-time interactive menus and bit-width cycling easily. For a production-ready consumer device, I would migrate to a **Scatter-Gather DMA** to free up 99% of CPU cycles, but for a prototype, the current approach ensures 'Bit-Perfect' delivery with predictable latency."

### Q3: "Explain the relationship between Bit-Depth and Dynamic Range."
*   **The Answer**: "The rule of thumb is **6 dB per bit**. 
    *   16-bit audio has a theoretical dynamic range of ~96 dB.
    *   24-bit audio has ~144 dB.
    *   In my implementation, even if the CPU sends 24-bit data, the signal quality is ultimately limited by the **Signal-to-Noise Ratio (SNR)** of the external PCM5102A DAC (which is ~112 dB)."

### Q4: "How do you know your Clock Domain Crossing (CDC) is actually working?"
*   **The Answer**: "I verified this through two methods:
    1.  **Static Timing Analysis (STA)**: Using Vivado's Timing Constraints (`set_false_path` or `set_max_delay`), I ensured that the tool understands these are asynchronous paths and places the Flip-Flops close together to minimize MTBF (Mean Time Between Failures).
    2.  **Hardware Loopback**: I performed stress tests where the CPU writes as fast as possible while the audio logic monitors a 'Toggle Bit' in a reserved register to confirm every single write event was captured."

---

## 11. The "Nyquist" Trap
**Question: "What happens if you set the DDS to 30 kHz while the sample rate is 48 kHz?"**

*   **The Answer**: "You will get **Aliasing**. According to the Nyquist-Shannon sampling theorem, we can only represent frequencies up to **Fs/2** (24 kHz). A 30 kHz request would 'fold back' into the audible range and appear as an 18 kHz tone ($48 - 30 = 18$). In my code, I have not implemented a software limit, but in a commercial product, the UI should cap the frequency at $0.45 \times Fs$."

---

## 12. Reset Strategy
**Question: "Why does your audio domain have its own 'Power-On Reset'?"**

*   **The Answer**: "Because the audio clock might not be running when the system resets (e.g., if the MMCM hasn't locked yet). My design uses a **Self-Timed Reset Shift Register** inside the audio domain. This ensures that the I2S state machine only starts *after* the audio clock is stable, preventing 'glitch' outputs that could damage speakers."
