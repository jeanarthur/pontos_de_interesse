import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String titlePlaceholder;
  final String subtitlePlaceholder;

  const Header({
    super.key,
    this.titlePlaceholder = 'Pontos de interesse',
    this.subtitlePlaceholder = 'distancia aqui',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue,
            Colors.grey,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: titlePlaceholder,
              hintStyle: theme.textTheme.headlineSmall?.copyWith(color: Colors.white70),
              border: InputBorder.none,
            ),
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          TextField(
            decoration: InputDecoration(
              hintText: subtitlePlaceholder,
              hintStyle: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
              border: InputBorder.none,
            ),
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(80);
}
