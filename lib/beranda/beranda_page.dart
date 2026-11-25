import 'package:billin/common/c_colors.dart';
import 'package:billin/common/c_container.dart';
import 'package:billin/common/c_icon_box.dart';
import 'package:billin/common/navbar.dart';
import 'package:billin/profile/profile_page.dart';
import 'package:billin/scan/scan_page.dart';
import 'package:billin/undangan/undangan_benar.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Data model lokal untuk Riwayat Split Bill
// ─────────────────────────────────────────────
class _SplitBillHistory {
  final String storeName;
  final String createdBy;
  final String nominal;
  final String date;
  final String memberLabel;

  const _SplitBillHistory({
    required this.storeName,
    required this.createdBy,
    required this.nominal,
    required this.date,
    required this.memberLabel,
  });
}

const List<_SplitBillHistory> _dummyHistory = [
  _SplitBillHistory(
    storeName: 'Toko Roti Ceri',
    createdBy: 'Dibuat oleh Anda',
    nominal: 'Rp. 350.000',
    date: '23/01/2021',
    memberLabel: 'Ayu Dewi dan 3 orang lainnya',
  ),
  _SplitBillHistory(
    storeName: 'Toko Roti Ceri',
    createdBy: 'Dibuat oleh Anda',
    nominal: 'Rp. 350.000',
    date: '23/01/2021',
    memberLabel: 'Ayu Dewi dan 3 orang lainnya',
  ),
  _SplitBillHistory(
    storeName: 'Toko Roti Ceri',
    createdBy: 'Dibuat oleh Anda',
    nominal: 'Rp. 350.000',
    date: '23/01/2021',
    memberLabel: 'Ayu Dewi dan 3 orang lainnya',
  ),
];

// Alias agar kompatibel baik sebagai BerandaPage maupun HomePage
typedef HomePage = BerandaPage;

// ─────────────────────────────────────────────
// Halaman Beranda (Home Screen)
// ─────────────────────────────────────────────
class BerandaPage extends StatefulWidget {
  final bool withNavbar;
  const BerandaPage({super.key, this.withNavbar = true});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int _navIndex = 0;

  @override
  void dispose() {
    _linkController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScanPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const _BerandaHeader(),
              const _DashboardGrid(),
              _JoinSplitBillCard(linkController: _linkController),
              _RiwayatSection(searchController: _searchController),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.withNavbar
          ? Navbar(
              currentIndex: _navIndex,
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                }
              },
              onScanTap: _openScanner,
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────
// A. Header Beranda
// ─────────────────────────────────────────────
class _BerandaHeader extends StatelessWidget {
  const _BerandaHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang,',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight(400),
                  color: CColors.text,
                ),
              ),
              Text(
                'Username',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight(700),
                  color: CColors.text,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.person,
              size: 28,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// B. Dashboard Summary (Grid 2x2)
// ─────────────────────────────────────────────
class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: const [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Total pengeluaran',
                mainValue: 'Rp. 2.090.158',
                sub1: 'Bulan ini',
                sub2: 'Rp. 421.550',
              ),
            ),
            Expanded(
              child: _SummaryCard(
                icon: Icons.credit_card_outlined,
                label: 'Total pengeluaran kamu',
                mainValue: 'Rp. 351.500',
                sub1: 'Bulan ini',
                sub2: 'Rp. 91.550',
              ),
            ),
          ],
        ),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.receipt_long_outlined,
                label: 'Total Split Bill',
                mainValue: '34 kali',
              ),
            ),
            Expanded(
              child: _SubscriptionCard(),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String mainValue;
  final String? sub1;
  final String? sub2;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.mainValue,
    this.sub1,
    this.sub2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: BoxBorder.all(color: CColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          CIconBox(
            icon: icon,
            iconColor: CColors.accent,
            backgroundColor: CColors.accent.withAlpha(25),
            size: 36,
            borderRadius: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: CColors.textGray,
                    fontWeight: FontWeight(400),
                  ),
                ),
                Text(
                  mainValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight(700),
                    color: CColors.text,
                  ),
                ),
                if (sub1 != null)
                  Text(
                    sub1!,
                    style: TextStyle(
                      fontSize: 10,
                      color: CColors.textGray,
                      fontWeight: FontWeight(400),
                    ),
                  ),
                if (sub2 != null)
                  Text(
                    sub2!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight(600),
                      color: CColors.text,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: BoxBorder.all(color: CColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: CColors.accent.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '12x',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight(700),
                color: CColors.accent,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  'Tempat Langganan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: CColors.textGray,
                    fontWeight: FontWeight(400),
                  ),
                ),
                Text(
                  'di Toko Roti Ceri',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight(700),
                    color: CColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// C. Join Split Bill Card
// ─────────────────────────────────────────────
class _JoinSplitBillCard extends StatelessWidget {
  final TextEditingController linkController;

  const _JoinSplitBillCard({required this.linkController});

  @override
  Widget build(BuildContext context) {
    return CContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 10,
            children: [
              CIconBox(
                icon: Icons.link_rounded,
                iconColor: CColors.accent,
                backgroundColor: CColors.accent.withAlpha(25),
                size: 40,
                borderRadius: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Bergabung ke Split Bill',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight(700),
                        color: CColors.text,
                      ),
                    ),
                    Text(
                      'Masukkan link undangan yang dibagikan oleh teman anda',
                      style: TextStyle(
                        fontSize: 11,
                        color: CColors.textGray,
                        fontWeight: FontWeight(400),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: linkController,
                    style: TextStyle(fontSize: 13, color: CColors.text),
                    decoration: InputDecoration(
                      hintText: 'www.linkundanganmakan.com',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: CColors.textGray,
                        fontWeight: FontWeight(400),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    showUndanganBenarDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Temukan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// D & E. Riwayat Split Bill + List
// ─────────────────────────────────────────────
class _RiwayatSection extends StatelessWidget {
  final TextEditingController searchController;

  const _RiwayatSection({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // Judul & "Semua (18)"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Split Bill',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight(700),
                color: CColors.text,
              ),
            ),
            Text(
              'Semua (18)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight(600),
                color: CColors.accent,
              ),
            ),
          ],
        ),

        // Search bar + filter icon
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: BoxBorder.all(color: CColors.border),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.search, color: CColors.accent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: TextStyle(fontSize: 13, color: CColors.text),
                  decoration: InputDecoration(
                    hintText: 'Cari judul tagihan',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: CColors.textGray,
                      fontWeight: FontWeight(400),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Icon(Icons.tune_rounded, color: CColors.textGray, size: 20),
              const SizedBox(width: 12),
            ],
          ),
        ),

        // List riwayat
        Column(
          spacing: 10,
          children: _dummyHistory
              .map((item) => _RiwayatCard(item: item))
              .toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Card item riwayat
// ─────────────────────────────────────────────
class _RiwayatCard extends StatelessWidget {
  final _SplitBillHistory item;

  const _RiwayatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: BoxBorder.all(color: CColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Baris atas: icon toko + nama + nominal & tanggal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CIconBox(
                icon: Icons.store_outlined,
                iconColor: CColors.accent,
                backgroundColor: CColors.accent.withAlpha(25),
                size: 44,
                borderRadius: 10,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      item.storeName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight(700),
                        color: CColors.text,
                      ),
                    ),
                    Text(
                      item.createdBy,
                      style: TextStyle(
                        fontSize: 12,
                        color: CColors.textGray,
                        fontWeight: FontWeight(400),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2,
                children: [
                  Text(
                    item.nominal,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight(700),
                      color: CColors.text,
                    ),
                  ),
                  Text(
                    item.date,
                    style: TextStyle(
                      fontSize: 11,
                      color: CColors.textGray,
                      fontWeight: FontWeight(400),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Baris bawah: avatar stack + "Lihat Rincian"
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _AvatarMemberStack(label: item.memberLabel)),
              GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Text(
                      'Lihat Rincian',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight(600),
                        color: CColors.accent,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: CColors.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Avatar stack anggota
// ─────────────────────────────────────────────
class _AvatarMemberStack extends StatelessWidget {
  static const double _size = 28.0;
  final String label;

  const _AvatarMemberStack({required this.label});

  @override
  Widget build(BuildContext context) {
    final avatars = <Widget>[
      _buildCircle(child: const Icon(Icons.person, size: _size * 0.65, color: Color(0xFF9E9E9E))),
      _buildCircle(child: const Icon(Icons.person, size: _size * 0.65, color: Color(0xFF9E9E9E))),
      _buildCircle(
        child: const Text(
          '2+',
          style: TextStyle(
            fontSize: _size * 0.38,
            fontWeight: FontWeight(600),
            color: Color(0xFF757575),
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < avatars.length; i++)
              Align(
                widthFactor: i == avatars.length - 1 ? 1.0 : 0.72,
                child: avatars[i],
              ),
          ],
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: CColors.textGray,
            fontWeight: FontWeight(400),
          ),
        ),
      ],
    );
  }

  Widget _buildCircle({required Widget child}) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(child: child),
    );
  }
}
