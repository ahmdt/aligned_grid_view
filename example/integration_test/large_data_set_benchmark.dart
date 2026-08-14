import 'package:flutter/material.dart';

const largeDataSetItemCount = 1000;
const largeDataSetCrossAxisCount = 2;
const largeDataSetMainAxisSpacing = 16.0;
const largeDataSetCrossAxisSpacing = 16.0;
const largeDataSetPadding = EdgeInsets.all(20);
const largeDataSetScrollableKey = ValueKey('large-data-set-scrollable');

const _titles = [
  'Quick update',
  'Project note',
  'Customer feedback',
  'Release checklist',
  'Research summary',
  'Team reminder',
];
const _icons = [
  Icons.bolt_outlined,
  Icons.note_alt_outlined,
  Icons.forum_outlined,
  Icons.task_alt_outlined,
  Icons.science_outlined,
  Icons.groups_outlined,
];
const _colors = [
  Color(0xfffff4cc),
  Color(0xffdff3e4),
  Color(0xffdcecff),
  Color(0xffffe4d6),
  Color(0xffeee1ff),
  Color(0xffd9f5f0),
];
final _cardTitles = List<String>.generate(
  largeDataSetItemCount,
  (index) => '${_titles[index % _titles.length]} ${index + 1}',
  growable: false,
);

class LargeDataSetCard extends StatelessWidget {
  const LargeDataSetCard({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    final description = switch (index % 12) {
      0 =>
        'This deliberately detailed entry represents a substantial update with several useful points for reviewers. It makes this row noticeably taller than the surrounding rows.',
      1 =>
        'This entry has a little more detail than a short note, but remains more compact than the detailed update nearby.',
      _ => 'A short piece of information.',
    };
    return Card(
      color: _colors[index % _colors.length],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icons[index % _icons.length]),
            const SizedBox(height: 24),
            Text(
              _cardTitles[index],
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}

class LargeDataSetBenchmarkApp extends StatelessWidget {
  const LargeDataSetBenchmarkApp({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
