import 'package:abc_learning_system/shared/widgets/bordered_surface.dart';
import 'package:abc_learning_system/shared/widgets/custom_ink_well_list.dart';
import 'package:flutter/material.dart';

class BorderedHeaderCell extends StatelessWidget {
  final int flex;
  final String text;

  const BorderedHeaderCell({super.key, required this.flex, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: _BorderedTitleCell(text: text),
    );
  }
}

class BorderedListView extends StatelessWidget {
  final int flex;
  final String title;
  final List items;
  final ValueChanged<int>? onItemTap;
  final bool expand;

  const BorderedListView({
    super.key,
    this.flex = 1,
    required this.title,
    required this.items,
    this.onItemTap,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BorderedTitleCell(text: title),
        BorderedSurface(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'No subjects found.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              : CustomInkWellList(
                  onChildTap: (index) {
                    if (onItemTap == null) {
                      return;
                    }

                    onItemTap!(index);
                  },
                  children: items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.subjectName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stub Code: ${item.stubCode}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );

    if (!expand) {
      return content;
    }

    return Expanded(flex: flex, child: content);
  }
}

class _BorderedTitleCell extends StatelessWidget {
  final String text;

  const _BorderedTitleCell({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BorderedSurface(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
