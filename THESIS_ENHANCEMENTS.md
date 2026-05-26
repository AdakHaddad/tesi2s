# Rencana Penambahan Materi Skripsi (Final Polish)

Dokumen ini berisi draf materi yang akan ditambahkan ke dalam file LaTeX untuk meningkatkan bobot akademik dan kualitas visual skripsi.

---

## 1. Analisis Resource Utilization (Bab V)

Tabel ini menunjukkan efisiensi desain IP I2S TX custom pada FPGA Artix-7 (XC7A35T).

### Tabel: Penggunaan Sumber Daya IP I2S TX (Estimasi)
| Resource | Used | Available | Utilization (%) |
| :--- | :--- | :--- | :--- |
| **LUT** (Look-up Table) | ~150 | 20,800 | < 1.0% |
| **FF** (Flip-Flop) | ~220 | 41,600 | < 1.0% |
| **BRAM** | 0 | 50 | 0.0% |
| **BUFG / BUFGMUX** | 1 | 32 | 3.1% |

**Narasi:**
Hasil implementasi menunjukkan bahwa IP I2S TX yang dirancang sangat ringan (*lightweight*). Penggunaan LUT dan FF yang berada di bawah 1% membuktikan bahwa arsitektur berbasis register tanpa FIFO asinkron sangat efisien untuk aplikasi SoC sederhana pada board Basys3.

---

## 2. Diagram Timing Formal (Bab II & IV)

### A. Protokol Philips I2S (Visualisasi)
- **BCLK:** Clock kontinu.
- **WS (LRCK):** Berubah 1 siklus BCLK *sebelum* MSB.
- **DATA:** Bit pertama (setelah WS transisi) adalah *delay bit* (0), diikuti MSB.

### B. Handshake AXI4-Lite Write
- **AWVALID & AWREADY:** Alamat diterima.
- **WVALID & WREADY:** Data diterima.
- **BVALID & BREADY:** Respon tulis selesai.

---

## 3. State Machine (FSM) Serializer (Bab IV)

Serializer bekerja berdasarkan counter `bit_count` (0-63) yang dapat direpresentasikan sebagai state:

1.  **IDLE:** Menunggu sinyal `ENABLE`.
2.  **WAIT_FRAME:** Menunggu sinkronisasi batas frame audio.
3.  **SEND_LEFT:** Mengirim 32 bit kanal kiri (1 bit delay + 31 bit data/padding).
4.  **SEND_RIGHT:** Mengirim 32 bit kanal kanan (1 bit delay + 31 bit data/padding).

---

## 4. Algoritma Deadline-Based Scheduling (Bab IV)

**Pseudo-code:**
```text
ALGORITMA Deadline_Scheduling:
    Input: Frekuensi_CPU, Target_Fs
    Output: Aliran sampel yang akurat secara timing

    1. Hitung Periode_Siklus = Frekuensi_CPU / Target_Fs
    2. Baca T_Sekarang dari register mcycle (64-bit)
    3. T_Deadline = T_Sekarang
    
    4. LOOP Selamanya:
        a. Panggil fungsi stream_sample() (Kirim data ke AXI)
        b. T_Deadline = T_Deadline + Periode_Siklus
        c. WHILE Baca_mcycle() < T_Deadline:
             // Tunggu (Busy-wait) hingga waktu tercapai
        d. Cek input UART untuk kendali user
```

---

## 5. Tabel Perbandingan IP (Bab V)

| Fitur | **IP I2S Custom (Skripsi)** | **Xilinx LogiCORE I2S** |
| :--- | :--- | :--- |
| **Antarmuka** | AXI4-Lite (Register) | AXI4-Stream |
| **Metode Transfer** | Programmed I/O (CPU) | DMA / Streaming |
| **Resource Usage** | Sangat Rendah (<200 LUT) | Moderat (>500 LUT) |
| **Fitur CDC** | Register-based counter | Asynchronous FIFO |
| **Tujuan Utama** | Edukasi & Validasi Protokol | Produksi & High-Throughput |

**Kesimpulan Pembahasan:**
Meskipun IP LogiCORE unggul dalam fitur, IP Custom ini memberikan keunggulan dalam hal kemudahan integrasi bare-metal tanpa perlu konfigurasi DMA yang kompleks, sehingga sangat ideal untuk sistem sensor atau audio sederhana pada platform FPGA berkapasitas kecil.
