import 'package:aligned_grid_view/aligned_grid_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aligned Grid View',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2364aa)),
        useMaterial3: true,
      ),
      home: const ExampleIndexPage(),
    );
  }
}

class ExampleIndexPage extends StatelessWidget {
  const ExampleIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = [
      _Example(
        title: 'Fixed columns',
        description: 'AlignedGridView.count with three columns.',
        icon: Icons.view_module_outlined,
        page: const CountExamplePage(),
      ),
      _Example(
        title: 'Responsive extent',
        description: 'AlignedGridView.extent adapts its column count.',
        icon: Icons.aspect_ratio_outlined,
        page: const ExtentExamplePage(),
      ),
      _Example(
        title: 'Custom scroll view',
        description: 'SliverAlignedGrid alongside other slivers.',
        icon: Icons.view_stream_outlined,
        page: const SliverExamplePage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Aligned Grid View')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Examples',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('Each row takes the height of its tallest tile.'),
              const SizedBox(height: 24),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 700 ? 3 : 1;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: crossAxisCount == 1 ? 3.2 : 0.7,
                      ),
                      itemCount: examples.length,
                      itemBuilder: (context, index) =>
                          _ExampleTile(example: examples[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.example});

  final _Example example;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (context) => example.page)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                example.icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Spacer(),
              Text(
                example.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(example.description),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CountExamplePage extends StatelessWidget {
  const CountExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ExampleScaffold(
      title: 'Fixed columns',
      description: 'Three tiles per row, each row aligned to its tallest tile.',
      child: AlignedGridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: _sampleCards.length,
        itemBuilder: (context, index) => _SampleCard(card: _sampleCards[index]),
      ),
    );
  }
}

class ExtentExamplePage extends StatelessWidget {
  const ExtentExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ExampleScaffold(
      title: 'Responsive extent',
      description:
          'Tiles stay below 240 pixels wide while columns adapt to space.',
      child: AlignedGridView.extent(
        padding: const EdgeInsets.all(20),
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: _sampleCards.length,
        itemBuilder: (context, index) => _SampleCard(card: _sampleCards[index]),
      ),
    );
  }
}

class SliverExamplePage extends StatelessWidget {
  const SliverExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom scroll view')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                'SliverAlignedGrid works with headers, lists, and other slivers.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverAlignedGrid.extent(
              maxCrossAxisExtent: 240,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: _sampleCards.length,
              itemBuilder: (context, index) =>
                  _SampleCard(card: _sampleCards[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleScaffold extends StatelessWidget {
  const _ExampleScaffold({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.card});

  final _SampleCardData card;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: card.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(card.icon),
            const SizedBox(height: 24),
            Text(card.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(card.description),
          ],
        ),
      ),
    );
  }
}

class _Example {
  const _Example({
    required this.title,
    required this.description,
    required this.icon,
    required this.page,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget page;
}

class _SampleCardData {
  const _SampleCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

const _sampleCards = [
  _SampleCardData(
    title: 'Short note',
    description: 'A compact tile.',
    icon: Icons.lightbulb_outline,
    color: Color(0xfffff4cc),
  ),
  _SampleCardData(
    title: 'Longer content',
    description:
        'This tile has a longer explanation, so the whole row grows to match it.',
    icon: Icons.subject_outlined,
    color: Color(0xffdff3e4),
  ),
  _SampleCardData(
    title: 'Status',
    description: 'Ready for review.',
    icon: Icons.check_circle_outline,
    color: Color(0xffdcecff),
  ),
  _SampleCardData(
    title: 'Another item',
    description: 'Rows are independent from one another.',
    icon: Icons.layers_outlined,
    color: Color(0xffffe4d6),
  ),
  _SampleCardData(
    title: 'Detailed card',
    description:
        'Content can differ substantially in length without leaving uneven tile bottoms in a row.',
    icon: Icons.format_align_left,
    color: Color(0xffeee1ff),
  ),
  _SampleCardData(
    title: 'Final tile',
    description: 'The last row can contain fewer tiles.',
    icon: Icons.flag_outlined,
    color: Color(0xffd9f5f0),
  ),
];
