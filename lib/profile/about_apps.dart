import 'package:billin/common/c_app_bar.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _blue = Color(0xFF2F80ED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CAppBar("Tentang Aplikasi"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _SectionTitle('Tujuan Aplikasi'),
              _NumberedList([
                'Membantu pengguna menghasilkan pembagian tagihan dengan waktu singkat dan perhitungan yang sesuai.',
                'Mengekstraksi data transaksi secara otomatis melalui pemindaian struk belanja.',
                'Memanfaatkan Vision Language Model (VLM) yang bisa menangani variasi format struk belanja saat proses ekstraksi data.',
              ]),
              SizedBox(height: 24),
              _SectionTitle('Teknologi Yang Digunakan'),
              _Paragraph(
                'Aplikasi ini mengintegrasikan teknologi Vision-Language Model (VLM) pada Fitur Pemindaian Struk untuk meningkatkan efisiensi dan akurasi dalam pengolahan data transaksi non-terstruktur. Melalui kapabilitas pemahaman multimodal, sistem mampu menganalisis struktur visual dokumen struk belanja secara komprehensif, mencakup identifikasi entitas seperti nama item, kuantitas, harga satuan, hingga komponen pajak dan diskon secara otomatis.',
              ),
              SizedBox(height: 24),
              _SectionTitle('Tim Pengembang'),
              _Paragraph(
                'Aplikasi ini dikembangkan oleh Kelompok 5B1 untuk memenuhi penilaian kegiatan Project Based Learning (PBL) Jurusan Teknologi Informasi Tahun Ajaran 2026/2027 di Kampus Politeknik Negeri Bali.',
              ),
              SizedBox(height: 24),
              _SectionTitle('Syarat & Ketentuan'),
              _NumberedList([
                'Penerimaan Ketentuan: Dengan mengunduh atau menggunakan aplikasi ini, Anda menyetujui untuk terikat oleh syarat dan ketentuan ini.',
                'Penggunaan Layanan: Aplikasi ini ditujukan untuk membantu kalkulasi pengeluaran kelompok dan pencatatan utang-piutang pribadi.',
                'Transaksi Finansial: Aplikasi ini tidak bertindak sebagai lembaga keuangan atau pemroses pembayaran langsung.',
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

/// Judul bagian
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AboutPage._blue,
        ),
      ),
    );
  }
}

/// Style teks isi
const _bodyStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w300,
  height: 1.5,
  color: Color(0xFFB6B6B6),
);

/// Paragraf rata kiri-kanan
class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: TextAlign.justify, style: _bodyStyle);
  }
}

/// Daftar bernomor dengan indentasi (nomor di kiri, teks lurus di kanan)
class _NumberedList extends StatelessWidget {
  final List<String> items;
  const _NumberedList(this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  child: Text('${i + 1}.', style: _bodyStyle),
                ),
                Expanded(
                  child: Text(
                    items[i],
                    textAlign: TextAlign.justify,
                    style: _bodyStyle,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
