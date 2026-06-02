import serial
import numpy as np
import matplotlib.pyplot as plt

# =========================
# SERIAL
# =========================

ser = serial.Serial(
    'COM6',
    921600
)

# =========================
# CAPTURE
# =========================

N = 8192
fs = 20000

raw = ser.read(N * 2)

data = np.frombuffer(
    raw,
    dtype='<i2'
)

# =========================
# TIME DOMAIN
# =========================

# plt.figure(figsize=(10,4))

# plt.plot(data[:1000])

# plt.title("Time Domain")

# plt.grid()

# plt.show()

# =========================
# FFT
# =========================

window = np.hanning(N)

fft_data = np.fft.fft(
    data * window
)

freq = np.fft.fftfreq(
    N,
    d=1/fs
)

half = N // 2

freq = freq[:half]

mag = np.abs(
    fft_data[:half]
)

mag /= np.max(mag)

peak = np.argmax(mag)

print(
    f"Peak Frequency = {freq[peak]:.2f} Hz"
)

# =========================
# PLOT FFT
# =========================

plt.figure(figsize=(10,4))

plt.plot(freq, mag)

plt.xlim(0, 1000)

plt.grid()

plt.title("FFT")

plt.show()