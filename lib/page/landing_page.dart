import 'dart:ui';
import 'dart:async';
import 'package:billin/main_screen.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>{
  final PageController _controller = PageController();
  int _current = 0;

  //TODO timer slider
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }
  
   void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final page = _controller.page?.round() ?? 0;
      final next = (page + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  //slide bar
  final List<_SlideData> _slides = const[
    _SlideData(
      subtitle: 'Selamat datang',
      title: 'Split Bill Apps',
      description: 'Aplikasi yang berguna untuk membagi tagihan belanja',
      image: 'assets/images/logo.png',
      bgColor: Colors.white
    ),
    _SlideData( //TODO masih bingung isi datanya
      // subtitle: 'Scan struk',
      title: 'Otomatis Terbaca',
      description: 'Foto struk belanja, data item dan harga langsung terisi',
      image: 'assets/images/slide2.png',
      bgColor: Color(0xff2196f3)
    ),
    _SlideData( //TODO masih bingung isi datanya
      // subtitle: 'Bagi tagihan',
      title: 'Adil & Akurat',
      description: 'Pajak dan diskon dibagi proporsional untuk tiap anggota',
      image: 'assets/images/slide3.png',
      bgColor: Color(0xff5bb8cc)
    ),
  ];

  static const _blue = Color(0xFF2563eB);
  static const _mint = Color(0xFF6EE7B7);
  
  //*nav ke halaman berikutnya
  void _onStart() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => const MainScreen())
    );
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, i) => _SlideView(data: _slides[i]),
              )
            ),
            _buildIndicator(),
            const SizedBox(height: 40),
            _buildButton(),
            const SizedBox(height: 56),
          ],  
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length,(i){
        final active = i == _current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: active ? const Color(0xff1e88e5) : const Color(0xffc4c4c4),
            borderRadius: BorderRadius.circular(2),
          ), 
        );
      }),
    );
  }

  Widget _buildButton(){
    return GestureDetector(
      onTap: _onStart,
      child: Container(
        width: 162,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [_mint, _blue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        ),
        child: const Text(
          'Mulai',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  final String? subtitle;
  final String title;
  final String description;
  final String image;
  final Color bgColor; 

  const _SlideData({
    this.subtitle,
    required this.title,
    required this.description,
    required this.image,
    this.bgColor = Colors.white,
  });
}

class _SlideView extends StatelessWidget {
  final _SlideData data;
  const _SlideView ({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Image.asset(
                data.image,
                width: 260,
                fit: BoxFit.contain,
                errorBuilder: (_, error, ___){
                  debugPrint('GAGAL LOAD ${data.image}: $error');
                  return const Icon(
                    Icons.receipt_long_rounded,
                    size: 160,
                    color: Colors.white,
                  );
                }
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 56, 48, 0),
            child: Column(
              children: [
               if (data.subtitle != null) ...[
                  Text(
                    data.subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFFA8A8A8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}