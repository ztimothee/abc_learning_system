import 'package:flutter/material.dart';

class CustomInkWellList extends StatelessWidget {
  final List<Widget> children;
  final ValueChanged<int>? onChildTap;
  final EdgeInsetsGeometry padding;
  final Duration animationDuration;

  const CustomInkWellList({
    super.key,
    required this.children,
    this.onChildTap,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    this.animationDuration = const Duration(milliseconds: 180),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children.asMap().entries.map((entry) {
        return _CustomInkWellListItem(
          index: entry.key,
          onTap: onChildTap,
          padding: padding,
          animationDuration: animationDuration,
          child: entry.value,
        );
      }).toList(),
    );
  }
}

class _CustomInkWellListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final ValueChanged<int>? onTap;
  final EdgeInsetsGeometry padding;
  final Duration animationDuration;

  const _CustomInkWellListItem({
    required this.index,
    required this.child,
    required this.onTap,
    required this.padding,
    required this.animationDuration,
  });

  @override
  State<_CustomInkWellListItem> createState() => _CustomInkWellListItemState();
}

class _CustomInkWellListItemState extends State<_CustomInkWellListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isInteractive = widget.onTap != null;
    final Color hoverColor = colorScheme.primary.withValues(alpha: 0.12);

    return MouseRegion(
      cursor: isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: isInteractive
          ? (_) {
              setState(() {
                _isHovered = true;
              });
            }
          : null,
      onExit: isInteractive
          ? (_) {
              setState(() {
                _isHovered = false;
              });
            }
          : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive ? () => widget.onTap!(widget.index) : null,
          child: AnimatedContainer(
            width: double.infinity,
            duration: widget.animationDuration,
            curve: Curves.easeOut,
            color: _isHovered ? hoverColor : Colors.transparent,
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
