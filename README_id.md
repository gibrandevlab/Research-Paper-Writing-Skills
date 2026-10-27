# 📝 Panduan Menulis Paper Riset dengan AI (Research Paper Writing Skills)

[English](./README.md) | [Bahasa Indonesia](./README_id.md) | [中文](./README_zh.md) | [日本語](./README_ja.md) | [العربية](./README_ar.md)

Selamat datang! Repositori ini dirancang khusus untuk membantu mahasiswa, dosen, dan peneliti menulis draf paper ilmiah (jurnal maupun konferensi internasional) berkualitas tinggi dengan bantuan AI. 

Anda **tidak perlu menjadi ahli pemrograman** untuk menggunakannya. Cukup pasang sekali, lalu ajak AI berdiskusi seperti mengobrol dengan rekan riset atau co-author berpengalaman.

---

## 🌟 Apa Manfaatnya untuk Anda?

Bukan sekadar memperbaiki tata bahasa Inggris biasa, keahlian (*skills*) ini membantu Anda menyusun struktur berpikir akademis yang kuat:

1. **Menulis Draf Lebih Cepat & Terarah**
   Membantu Anda menyusun bagian demi bagian secara berurutan: mulai dari *Abstract*, *Introduction*, *Method*, *Experiments*, hingga *Conclusion*.
2. **Membuat Alur Tulisan Mengalir (*Flow*)**
   Mengatur paragraf agar tidak melompat-lompat atau berulang-ulang, sehingga argumen Anda mudah dipahami dan enak dibaca reviewer.
3. **Mencegah Penolakan Akibat Klaim Tanpa Bukti**
   AI akan memeriksa secara teliti: setiap kali Anda membuat klaim penting, AI memastikan ada tabel, grafik, atau referensi yang mendukungnya.
4. **Simulasi Reviewer Kritis (*Pre-Submission Self-Review*)**
   Melihat naskah Anda dari sudut pandang reviewer jurnal yang ketat untuk menemukan celah, pertanyaan yang belum terjawab, atau kelemahan eksperimen sebelum paper diserahkan (*submit*).
5. **Konsistensi Istilah Sepanjang Paper**
   Memastikan istilah konsep, singkatan, dan angka statistik yang Anda sebut di *Abstract* tetap konsisten di bagian metodologi dan kesimpulan.
6. **Ingatan Riset yang Berkelanjutan**
   AI mengingat konteks penelitian Anda meskipun sesi tanya-jawab ditutup dan dilanjutkan di hari lain.

---

## 🚀 3 Langkah Setup (Cukup Sekali)

Pilihlah petunjuk yang sesuai dengan sistem operasi komputer Anda.

### Untuk Pengguna Windows

#### Langkah 1: Unduh Repositori
Buka **PowerShell** di komputer Anda, lalu jalankan perintah berikut:
```powershell
git clone https://github.com/Master-cai/Research-Paper-Writing-Skills.git
cd Research-Paper-Writing-Skills
```
*(Atau Anda bisa langsung mengunduh file ZIP dari halaman web GitHub dan mengekstraknya ke folder kerja Anda).*

#### Langkah 2: Pasang ke Asisten AI Anda
Pilih salah satu AI yang Anda gunakan:

- **Jika Anda menggunakan Cursor, Cline, atau GitHub Copilot:**
  - Cukup buka folder `Research-Paper-Writing-Skills` menggunakan Cursor atau VS Code. Panduan dan aturan penulisan akan **aktif secara otomatis** tanpa langkah tambahan!

- **Jika Anda menggunakan Claude Code:**
  Salin dan jalankan perintah ini di PowerShell:
  ```powershell
  New-Item -ItemType Directory -Force "$HOME\.claude\skills"
  Copy-Item -Recurse -Force research-paper-writing "$HOME\.claude\skills\"
  ```

- **Jika Anda menggunakan Gemini CLI:**
  Salin dan jalankan perintah ini di PowerShell:
  ```powershell
  New-Item -ItemType Directory -Force "$HOME\.gemini\skills"
  Copy-Item -Recurse -Force research-paper-writing "$HOME\.gemini\skills\"
  ```

- **Jika Anda menggunakan Codex:**
  Salin dan jalankan perintah ini di PowerShell:
  ```powershell
  New-Item -ItemType Directory -Force "$env:CODEX_HOME\skills"
  Copy-Item -Recurse -Force research-paper-writing "$env:CODEX_HOME\skills\"
  ```

#### Langkah 3: Selesai!
Sekarang AI Anda sudah memiliki keahlian menulis paper riset.

---

### Untuk Pengguna Mac / Linux

#### Langkah 1: Unduh Repositori
Buka **Terminal**, lalu jalankan:
```bash
git clone https://github.com/Master-cai/Research-Paper-Writing-Skills.git
cd Research-Paper-Writing-Skills
```
*(Atau unduh file ZIP dari GitHub dan ekstrak ke komputer Anda).*

#### Langkah 2: Pasang ke Asisten AI Anda
Pilih sesuai asisten yang Anda gunakan:

- **Jika Anda menggunakan Cursor, Cline, atau GitHub Copilot:**
  - Cukup buka folder hasil unduhan di aplikasi Cursor atau VS Code. Semua aturan otomatis siap digunakan!

- **Jika Anda menggunakan Claude Code:**
  Salin dan jalankan perintah ini di Terminal:
  ```bash
  mkdir -p "$HOME/.claude/skills"
  cp -R research-paper-writing "$HOME/.claude/skills/"
  ```

- **Jika Anda menggunakan Gemini CLI:**
  Salin dan jalankan perintah ini di Terminal:
  ```bash
  mkdir -p "$HOME/.gemini/skills"
  cp -R research-paper-writing "$HOME/.gemini/skills/"
  ```

- **Jika Anda menggunakan Codex:**
  Salin dan jalankan perintah ini di Terminal:
  ```bash
  mkdir -p "$CODEX_HOME/skills"
  cp -R research-paper-writing "$CODEX_HOME/skills/"
  ```

#### Langkah 3: Selesai!
Asisten AI Anda siap mendampingi penulisan naskah Anda.

---

## 💬 Cara Pakai Sehari-hari

Anda **tidak perlu memikirkan teknis perintah atau skrip di belakang layar**. AI akan bekerja secara otomatis memandu Anda. 

Cukup buka asisten AI favorit Anda dan ketikkan pertanyaan atau perintah dalam bahasa sehari-hari (bisa Bahasa Indonesia maupun Bahasa Inggris).

### Contoh Pertanyaan / Perintah yang Bisa Anda Gunakan:

- **Menyusun Bagian Introduction:**
  > *"Tolong bantu saya menyusun draf Introduction berdasarkan poin-poin ide riset berikut: [tempel poin-poin Anda]. Gunakan struktur: latar belakang masalah, tantangan yang ada, solusi yang saya usulkan, dan keunggulan metode saya."*

- **Memperbaiki Alur Tulisan (Flow):**
  > *"Berikut draf bagian Metodologi saya. Tolong baca dan perbaiki alur antarkalimat dan antarparagrafnya agar transisinya halus dan mudah dipahami pembaca."*

- **Pemeriksaan Klaim & Bukti:**
  > *"Periksa draf bagian Diskusi ini. Apakah ada pernyataan klaim yang belum didukung oleh data eksperimen atau referensi yang memadai?"*

- **Simulasi Reviewer Jurnal:**
  > *"Berperanlah sebagai reviewer jurnal yang teliti dan kritis. Tolong review draf Abstrak berikut dan beri masukan bagian mana yang masih lemah atau membingungkan."*

- **Menyelaraskan Istilah:**
  > *"Tolong cek apakah istilah teknis dan penamaan metode yang saya gunakan di bagian Abstrak sudah konsisten dengan yang tertulis di bagian Hasil."*

---

## 🤖 Asisten AI yang Didukung

Repositori ini kompatibel dengan berbagai asisten AI modern:

| Asisten AI | Cara Kerja |
| :--- | :--- |
| **Cursor** | Cukup buka folder proyek di Cursor; panduan aktif otomatis. |
| **Claude Code** | Asisten terminal cerdas dari Anthropic. |
| **Cline** | Ekstensi AI yang terpasang di VS Code. |
| **GitHub Copilot** | Bekerja langsung di editor kode dengan panduan instruksi otomatis. |
| **Gemini CLI** | Asisten berbasis model Google Gemini. |
| **Codex** | Lingkungan AI coding dengan dukungan sistem keahlian (*skills*). |

---

## 🙏 Penghargaan & Sumber (Attribution)

Metodologi dan keahlian menulis dalam repositori ini bersumber dari kontribusi para peneliti luar biasa:

1. **Prof. Peng Sida (彭思达)**
   Hampir seluruh metodologi, panduan logika, dan pengalaman menulis paper berkelas dunia berasal dari catatan studi terbuka beliau:
   - [Catatan Studi Terbuka Prof. Peng Sida (Notion)](https://pengsida.notion.site/c1a22465a0fa4b15a12985223916048e)
   - [Repositori Asli Prof. Peng Sida di GitHub](https://github.com/pengsida/learning_research)
   
   Terima kasih yang sebesar-besarnya kepada Prof. Peng Sida atas kerelaan membagikan ilmu berharga ini secara terbuka kepada komunitas akademik.

2. **Master-cai**
   Penyusun awal yang mengorganisasi, menstrukturkan materi, dan mengemas panduan Prof. Peng Sida ke dalam format Skills yang siap pakai:
   - [Repositori Master-cai/Research-Paper-Writing-Skills](https://github.com/Master-cai/Research-Paper-Writing-Skills)

3. **Pengembangan & Penyempurnaan**
   Diadaptasi dan dikembangkan lebih lanjut dengan sistem memori kolaboratif lintas-AI oleh Afwan Gibran Muhammad Algiffari (2026).

---

## 📄 Lisensi

Repositori ini didistribusikan di bawah lisensi terbuka **MIT License**. Anda bebas menggunakan, memodifikasi, dan membagikannya untuk keperluan penelitian mandiri, pendidikan, maupun publikasi ilmiah. Lihat dokumen [LICENSE](./LICENSE) untuk detail lengkap.
