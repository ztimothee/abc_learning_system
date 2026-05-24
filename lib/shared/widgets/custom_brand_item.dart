import 'package:flutter/material.dart';

class CustomBrandItem extends StatelessWidget {
  final String title;
  final Image logo;

  const CustomBrandItem({super.key, required this.title, required this.logo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
