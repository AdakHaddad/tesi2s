/*****************************************************************************
 * I2S software-DDS sample source
 *
 * RTL CONTROL register map:
 *   bit[0]    ENABLE          1 = transmit I2S
 *   bit[1]    MUTE            1 = send zero samples, clocks continue
 *   bit[6:2]  SAMPLE_WIDTH    1-31 literal, 0 encodes 32 bit
 *   bit[26:7] SAMPLE_RATE_HZ  sample rate in Hz
 *   bit[31:27] RESERVED       ignored by RTL
 *
 * The RTL no longer has a waveform generator. This app generates the test waveform
 * in software and writes PCM samples to DATA_LEFT/DATA_RIGHT.
 *****************************************************************************/

#include <stdint.h>
#include <ctype.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "xuartlite_l.h"

#if defined(XPAR_I2S_DDS_0_BASEADDR)
#define I2S_BASE XPAR_I2S_DDS_0_BASEADDR
#elif defined(XPAR_I2S_0_BASEADDR)
#define I2S_BASE XPAR_I2S_0_BASEADDR
#else
#error "Cannot find I2S base address in xparameters.h"
#endif

#define DATA_LEFT   (I2S_BASE + 0x00U)
#define DATA_RIGHT  (I2S_BASE + 0x04U)
#define CONTROL     (I2S_BASE + 0x08U)
#define STATUS_REG  (I2S_BASE + 0x0CU)

#define CTRL_ENABLE      (1U << 0)
#define CTRL_MUTE        (1U << 1)
#define CTRL_WIDTH(w)    (((uint32_t)((w) >= 32U ? 0U : ((w) & 0x1FU))) << 2U)
#define CTRL_RATE(hz)    (((uint32_t)(hz) & 0x000FFFFFU) << 7U)

#define DEFAULT_SAMPLE_RATE_HZ 48000U
#define MAX_SAMPLE_RATE_HZ     195312U
#define DEFAULT_WIDTH          16U
#define AMPLITUDE              32000

typedef enum { CH_BOTH = 0, CH_LEFT = 1, CH_RIGHT = 2 } ch_route_t;

static const int16_t SINE[32] = {
         0,   6393,  12539,  18204,  23170,  27245,  30273,  32137,
     32767,  32137,  30273,  27245,  23170,  18204,  12539,   6393,
         0,  -6393, -12539, -18204, -23170, -27245, -30273, -32137,
    -32767, -32137, -30273, -27245, -23170, -18204, -12539,  -6393
};

static uint8_t    g_enable          = 1U;
static uint8_t    g_mute            = 0U;
static uint8_t    g_width           = DEFAULT_WIDTH;
static uint8_t    g_square          = 0U;
static uint16_t   g_tone_freq_hz    = 1000U;
static uint32_t   g_sample_rate_hz  = DEFAULT_SAMPLE_RATE_HZ;
static ch_route_t g_channel         = CH_BOTH;
static uint32_t   g_phase           = 0U;
static uint32_t   g_last_frame_bit  = 0U;

static uint32_t clamp_sample_rate(uint32_t hz)
{
    if (hz == 0U)
        return DEFAULT_SAMPLE_RATE_HZ;
    if (hz > MAX_SAMPLE_RATE_HZ)
        return MAX_SAMPLE_RATE_HZ;
    return hz;
}

static uint8_t clamp_width(uint32_t width)
{
    if (width == 0U || width >= 32U)
        return 32U;
    return (uint8_t)width;
}

static uint32_t control_word(void)
{
    uint32_t ctrl = 0U;
    if (g_enable)
        ctrl |= CTRL_ENABLE;
    if (g_mute)
        ctrl |= CTRL_MUTE;
    ctrl |= CTRL_WIDTH(g_width);
    ctrl |= CTRL_RATE(g_sample_rate_hz);
    return ctrl;
}

static void apply_control(void)
{
    uint32_t ctrl = control_word();
    Xil_Out32(CONTROL, ctrl);
    xil_printf("   CTRL = 0x%08lX\r\n", (unsigned long)ctrl);
}

static uint32_t frame_status_bit(void)
{
    return Xil_In32(STATUS_REG) & 1U;
}

static uint32_t pack_sample(int16_t sample)
{
    int32_t value = (int32_t)sample;

    if (g_width >= 32U)
        value <<= 16;
    else if (g_width > 16U)
        value <<= (g_width - 16U);
    else if (g_width < 16U)
        value >>= (16U - g_width);

    return (uint32_t)value;
}

static void write_channels(uint32_t sample)
{
    uint32_t left = sample;
    uint32_t right = sample;

    if (!g_enable || g_mute) {
        left = 0U;
        right = 0U;
    } else {
        if (g_channel == CH_RIGHT)
            left = 0U;
        if (g_channel == CH_LEFT)
            right = 0U;
    }

    Xil_Out32(DATA_LEFT, left);
    Xil_Out32(DATA_RIGHT, right);
}

static void stream_software_dds_sample(void)
{
    uint32_t step = (uint32_t)(((uint64_t)g_tone_freq_hz << 32) / g_sample_rate_hz);
    int16_t sample = g_square
                   ? (g_phase & 0x80000000U ? (int16_t)AMPLITUDE : (int16_t)-AMPLITUDE)
                   : (int16_t)(((int32_t)SINE[g_phase >> 27] * AMPLITUDE) / 32767);

    write_channels(pack_sample(sample));
    g_phase += step;
}

static void set_enable(uint8_t value)
{
    g_enable = value ? 1U : 0U;
    xil_printf(">> %-14s = %u\r\n", "ENABLE", (unsigned)g_enable);
    apply_control();
    if (!g_enable)
        write_channels(0U);
    g_last_frame_bit = frame_status_bit();
}

static void set_mute(uint8_t value)
{
    g_mute = value ? 1U : 0U;
    xil_printf(">> %-14s = %s\r\n", "MUTE", g_mute ? "1 (silence)" : "0 (audio)");
    apply_control();
}

static void set_wave_square(uint8_t value)
{
    g_square = value ? 1U : 0U;
    xil_printf(">> %-14s = %s\r\n", "WAVE", g_square ? "Square" : "Sine");
}

static void set_tone_freq(uint32_t hz)
{
    if (hz > 65535U)
        hz = 65535U;
    g_tone_freq_hz = (uint16_t)hz;
    xil_printf(">> %-14s = %u Hz\r\n", "TONE FREQ", (unsigned)g_tone_freq_hz);
}

static void set_sample_rate(uint32_t hz)
{
    g_sample_rate_hz = clamp_sample_rate(hz);
    xil_printf(">> %-14s = %lu Hz\r\n", "SAMPLE RATE", (unsigned long)g_sample_rate_hz);
    apply_control();
    g_last_frame_bit = frame_status_bit();
}

static void set_width(uint32_t width)
{
    g_width = clamp_width(width);
    xil_printf(">> %-14s = %u bit\r\n", "SAMPLE WIDTH", (unsigned)g_width);
    apply_control();
}

static void set_channel(ch_route_t channel)
{
    g_channel = channel;
    xil_printf(">> %-14s = %s\r\n", "CHANNEL",
               channel == CH_LEFT ? "Left only" :
               channel == CH_RIGHT ? "Right only" : "Both");
}

static void print_state(void)
{
    xil_printf("\r\n=============================\r\n");
    xil_printf("  I2S Software DDS Test\r\n");
    xil_printf("=============================\r\n");
    xil_printf(">> %-14s = %u\r\n", "ENABLE", (unsigned)g_enable);
    xil_printf(">> %-14s = %s\r\n", "MUTE", g_mute ? "1 (silence)" : "0 (audio)");
    xil_printf(">> %-14s = %s\r\n", "WAVE", g_square ? "Square" : "Sine");
    xil_printf(">> %-14s = %u Hz\r\n", "TONE FREQ", (unsigned)g_tone_freq_hz);
    xil_printf(">> %-14s = %lu Hz\r\n", "SAMPLE RATE", (unsigned long)g_sample_rate_hz);
    xil_printf(">> %-14s = %u bit\r\n", "SAMPLE WIDTH", (unsigned)g_width);
    xil_printf("-----------------------------\r\n");
    xil_printf(" S      toggle sine/square\r\n");
    xil_printf(" +/-    tone freq +100/-100 Hz\r\n");
    xil_printf(" */_    tone freq +1k/-1k Hz\r\n");
    xil_printf(" 1/2/3  tone freq 1k/2k/5k\r\n");
    xil_printf(" 4/5/6  sample rate 48k/44.1k/96k\r\n");
    xil_printf(" [/]    sample rate -1k/+1k Hz\r\n");
    xil_printf(" W/X/Y  width 16/24/32 bit\r\n");
    xil_printf(" E      toggle ENABLE\r\n");
    xil_printf(" M      toggle MUTE\r\n");
    xil_printf(" L/R/B  left/right/both channels\r\n");
    xil_printf(" ?      show this menu\r\n");
    xil_printf("=============================\r\n");
}

static uint16_t clamp_u16(uint32_t value)
{
    return (uint16_t)(value > 65535U ? 65535U : value);
}

static void handle_key(uint8_t ch)
{
    uint8_t lower = (uint8_t)tolower((int)ch);
    xil_printf("%c\r\n", (char)ch);

    switch (lower) {
        case 's': set_wave_square(!g_square); break;
        case '+': case '=':
            set_tone_freq(clamp_u16((uint32_t)g_tone_freq_hz + 100U));
            break;
        case '-':
            set_tone_freq(g_tone_freq_hz > 100U ? g_tone_freq_hz - 100U : 0U);
            break;
        case '*':
            set_tone_freq(clamp_u16((uint32_t)g_tone_freq_hz + 1000U));
            break;
        case '_':
            set_tone_freq(g_tone_freq_hz > 1000U ? g_tone_freq_hz - 1000U : 0U);
            break;
        case '1': set_tone_freq(1000U); break;
        case '2': set_tone_freq(2000U); break;
        case '3': set_tone_freq(5000U); break;
        case '4': set_sample_rate(48000U); break;
        case '5': set_sample_rate(44100U); break;
        case '6': set_sample_rate(96000U); break;
        case '[':
            set_sample_rate(g_sample_rate_hz > 1000U ? g_sample_rate_hz - 1000U : 1U);
            break;
        case ']':
            set_sample_rate(g_sample_rate_hz + 1000U);
            break;
        case 'w': set_width(16U); break;
        case 'x': set_width(24U); break;
        case 'y': set_width(32U); break;
        case 'e': set_enable(!g_enable); break;
        case 'm': set_mute(!g_mute); break;
        case 'l': set_channel(CH_LEFT); break;
        case 'r': set_channel(CH_RIGHT); break;
        case 'b': set_channel(CH_BOTH); break;
        case '?': print_state(); break;
        default: break;
    }
}

int main(void)
{
    init_platform();
    xil_printf("\r\n=== I2S Software DDS Source ===\r\n");

    g_sample_rate_hz = clamp_sample_rate(g_sample_rate_hz);
    g_width = clamp_width(g_width);
    write_channels(0U);
    apply_control();
    g_last_frame_bit = frame_status_bit();
    print_state();

    while (1) {
        uint32_t frame_bit = frame_status_bit();

        if (g_enable && frame_bit != g_last_frame_bit) {
            g_last_frame_bit = frame_bit;
            stream_software_dds_sample();
        }

        if (!XUartLite_IsReceiveEmpty(STDIN_BASEADDRESS))
            handle_key((uint8_t)XUartLite_RecvByte(STDIN_BASEADDRESS));
    }

    cleanup_platform();
    return 0;
}
