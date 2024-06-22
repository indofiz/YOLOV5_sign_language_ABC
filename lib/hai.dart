import 'package:flutter/material.dart';

// CLASS UNTUK MENAMPILKAN GAMBAR DAN SAMBUTAN SELAMAT DATANG
class HaiWidget extends StatelessWidget {
  const HaiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/hai.png',
            width: 280,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Selamat Datang',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 40),
            child: Text(
              'Klik Menu Dibawah Untuk Menguji Penggunaan Aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black38,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
