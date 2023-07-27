import 'package:flutter/material.dart';

class ConfigAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ConfigAppBar({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton(itemBuilder: (context) {
          return [
            PopupMenuItem<int>(
              value: 0,
              child: Text(title),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Text("Settings"),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Text("Logout"),
            ),
          ];
        }, onSelected: (value) {
          if (value == 0) {
            print("My account menu is selected.");
          } else if (value == 1) {
            print("Settings menu is selected.");
          } else if (value == 2) {
            print("Logout menu is selected.");
          }
        }),
      ],
    );
  }
}
