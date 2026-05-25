import 'package:flutter/material.dart';

class CustomNavigationActionsItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomNavigationActionsItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<CustomNavigationActionsItem> createState() => _CustomNavigationActionsItemState();
}

class _CustomNavigationActionsItemState extends State<CustomNavigationActionsItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          color: _isHovering
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          child: Row(
            children: [
              Icon(widget.icon, size: 20),
              const SizedBox(width: 8),
              Text(widget.label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}