import 'package:flutter/material.dart';

class InternetError extends StatelessWidget {
  const InternetError({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logoBrycen.png'),
          const Icon(
            Icons.wifi_off,
            size: 40,
          ),
          const Text(
            'Please check your internet connection',
            textAlign: TextAlign.end,
            textScaleFactor: 1.5,
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
