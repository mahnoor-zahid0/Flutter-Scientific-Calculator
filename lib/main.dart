// lib/main.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// ---------------- Providers ----------------
final themeColorProvider = StateProvider<Color>((ref) => Colors.deepOrange);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
final isScientificProvider = StateProvider<bool>((ref) => false);

/// ---------------- Calculator state (Riverpod) ----------------
class CalcState {
  final String expr;
  final String result;
  const CalcState({this.expr = '', this.result = ''});
  CalcState copyWith({String? expr, String? result}) =>
      CalcState(expr: expr ?? this.expr, result: result ?? this.result);
}

class CalcNotifier extends StateNotifier<CalcState> {
  CalcNotifier() : super(const CalcState());

  void append(String s) => state = state.copyWith(expr: state.expr + s);
  void clear() => state = const CalcState();
  void delete() {
    if (state.expr.isNotEmpty) {
      state = state.copyWith(expr: state.expr.substring(0, state.expr.length - 1));
    }
  }

  void evaluate() {
    try {
      String e = state.expr
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100')
          .replaceAll('π', '${math.pi}')
          .replaceAll('e', '${math.e}')
          .replaceAll('√', 'sqrt');

      // factorial n! -> compute value
      if (e.contains('!')) {
        e = e.replaceAllMapped(RegExp(r'(\d+)!'), (m) {
          final n = int.parse(m.group(1)!);
          return _factorial(n).toString();
        });
      }

      Parser p = Parser();
      Expression ex = p.parse(e);
      final res = ex.evaluate(EvaluationType.REAL, ContextModel());
      String out = res.toString();
      if (out.endsWith('.0')) out = out.substring(0, out.length - 2);
      state = state.copyWith(result: out);
    } catch (_) {
      state = state.copyWith(result: 'Error');
    }
  }

  int _factorial(int n) => (n <= 1) ? 1 : n * _factorial(n - 1);
}

final calcProvider = StateNotifierProvider<CalcNotifier, CalcState>((ref) => CalcNotifier());

/// ---------------- App ----------------
class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(themeColorProvider);
    final mode = ref.watch(themeModeProvider);

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light).primary,
        foregroundColor: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light).onPrimary,
        iconTheme: IconThemeData(color: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light).onPrimary),
        actionsIconTheme: IconThemeData(color: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light).onPrimary),
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark).primary,
        foregroundColor: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark).onPrimary,
        iconTheme: IconThemeData(color: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark).onPrimary),
        actionsIconTheme: IconThemeData(color: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark).onPrimary),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scientific Calculator',
      theme: light,
      darkTheme: dark,
      themeMode: mode,
      home: const CalculatorScreen(),
    );
  }
}

/// ---------------- Calculator screen ----------------
class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScientific = ref.watch(isScientificProvider);
    final mode = ref.watch(themeModeProvider);
    final color = ref.watch(themeColorProvider);

    return Scaffold(
      // explicit hamburger leading to ensure visible 3-bar icon
      appBar: AppBar(
        leading: Builder(builder: (ctx) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Open menu',
          );
        }),
        title: const Text('Calculator'),
        actions: [
          // Scientific toggle (left of theme toggle)
          IconButton(
            tooltip: isScientific ? 'Switch to Basic' : 'Switch to Scientific',
            icon: Icon(isScientific ? Icons.science : Icons.calculate),
            onPressed: () {
              ref.read(isScientificProvider.notifier).state = !isScientific;
            },
          ),
          // Theme mode toggle (sun/moon) - forced visible by AppBarTheme in ThemeData
          IconButton(
            tooltip: 'Toggle theme mode',
            icon: Icon(ref.watch(themeModeProvider) == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              final cur = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state = cur == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      drawer: _buildDrawer(ref, context),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isScientificMode = ref.watch(isScientificProvider);
          return isScientificMode
              ? LandscapeLayout(constraints: constraints)
              : PortraitLayout(constraints: constraints);
        }),
      ),
    );
  }

  Drawer _buildDrawer(WidgetRef ref, BuildContext context) {
    final colors = [Colors.deepOrange, Colors.blue, Colors.teal, Colors.purple, Colors.green, Colors.indigo];
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: ref.watch(themeColorProvider)),
              child: const Text('Theme', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Choose primary color:')),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((c) {
                  return GestureDetector(
                    onTap: () {
                      ref.read(themeColorProvider.notifier).state = c;
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(backgroundColor: c),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(ref.watch(themeModeProvider) == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Toggle Light / Dark'),
              onTap: () {
                final cur = ref.read(themeModeProvider);
                ref.read(themeModeProvider.notifier).state = cur == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Reset to defaults'),
              onTap: () {
                ref.read(themeColorProvider.notifier).state = Colors.deepOrange;
                ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Portrait layout ----------------
class PortraitLayout extends ConsumerWidget {
  final BoxConstraints constraints;
  const PortraitLayout({required this.constraints, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calc = ref.watch(calcProvider);
    final notifier = ref.read(calcProvider.notifier);

    final totalH = constraints.maxHeight;
    final displayH = totalH * 0.26;
    final gridH = totalH - displayH;

    // grid: 4 columns x 5 rows
    const cols = 4;
    const rows = 5;
    final spacing = 8.0;
    final usableWidth = constraints.maxWidth - (spacing * (cols + 1));
    final itemW = usableWidth / cols;
    final usableHeight = gridH - (spacing * (rows + 1));
    final itemH = usableHeight / rows;
    final cellSize = (itemW < itemH ? itemW : itemH).clamp(36.0, 120.0);
    final childAspectRatio = (itemW > 0 && itemH > 0) ? (itemW / itemH) : 1.0;

    final buttons = [
      'AC', 'DEL', '%', '÷',
      '7','8','9','×',
      '4','5','6','-',
      '1','2','3','+',
      '0','.','π','='
    ];

    return Column(
      children: [
        SizedBox(height: displayH, child: _Display(areaHeight: displayH, expr: calc.expr, result: calc.result, isScientific: false)),
        SizedBox(
          height: gridH,
          child: Padding(
            padding: EdgeInsets.all(spacing),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
              children: buttons.map((b) {
                return _CalcButton(
                  label: b,
                  onTap: () => _handlePress(b, notifier),
                  size: cellSize,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------- Landscape layout (10 columns) ----------------
class LandscapeLayout extends ConsumerWidget {
  final BoxConstraints constraints;
  const LandscapeLayout({required this.constraints, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calc = ref.watch(calcProvider);
    final notifier = ref.read(calcProvider.notifier);

    final row1 = ['AC','DEL','%','÷','sin','cos','tan','ln','log','√'];
    final row2 = ['7','8','9','×','sinh','cosh','tanh','π','e','^'];
    final row3 = ['4','5','6','-','x²','x³','xʸ','10ˣ','eˣ','!'];
    final row4 = ['1','2','3','+','sin⁻¹','cos⁻¹','tan⁻¹','Rand','(',')'];
    final row5 = ['0','.','=','','','','','','',''];

    final buttons = [...row1, ...row2, ...row3, ...row4, ...row5];

    final totalW = constraints.maxWidth;
    final totalH = constraints.maxHeight;
    final displayH = totalH * 0.24; // slightly smaller display to leave room for 5 rows
    final gridH = totalH - displayH;
    const cols = 10;
    const rows = 5;
    final spacing = 6.0;

    final usableWidth = totalW - (spacing * (cols + 1));
    final itemW = usableWidth / cols;
    final usableHeight = gridH - (spacing * (rows + 1));
    final itemH = usableHeight / rows;
    final cellSize = (itemW < itemH ? itemW : itemH).clamp(28.0, 110.0);
    final childAspectRatio = (itemW > 0 && itemH > 0) ? (itemW / itemH) : 1.0;

    return Column(
      children: [
        SizedBox(height: displayH, child: _Display(areaHeight: displayH, expr: calc.expr, result: calc.result, isScientific: true)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(spacing),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
              children: buttons.map((b) {
                if (b.isEmpty) return const SizedBox.shrink();
                return _CalcButton(
                  label: b,
                  onTap: () => _handlePress(b, notifier),
                  size: cellSize,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------- Display widget ----------------
class _Display extends StatelessWidget {
  final double areaHeight;
  final String expr;
  final String result;
  final bool isScientific;
  const _Display({required this.areaHeight, required this.expr, required this.result, required this.isScientific, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // smaller fonts for scientific mode (to avoid oversized text)
    final exprFont = isScientific ? (areaHeight * 0.10) : (areaHeight * 0.12);
    final resFont = isScientific ? (areaHeight * 0.14) : (areaHeight * 0.18);

    final exprStyle = theme.textTheme.titleMedium?.copyWith(fontSize: exprFont);
    final resStyle = theme.textTheme.headlineMedium?.copyWith(fontSize: resFont, fontWeight: FontWeight.w700);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.bottomRight,
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(expr, style: exprStyle, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(result, style: resStyle),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Circular button ----------------
class _CalcButton extends ConsumerWidget {
  final String label;
  final VoidCallback onTap;
  final double size; // cell size (square)
  const _CalcButton({required this.label, required this.onTap, required this.size, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = ref.watch(themeColorProvider);
    final theme = Theme.of(context);
    final isOp = _isOperator(label);
    final bg = isOp ? primary : theme.colorScheme.surface.withOpacity(theme.brightness == Brightness.dark ? 0.12 : 1.0);
    final fg = isOp ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    // diameter slightly smaller than cell to allow spacing
    final diameter = (size * 0.86).clamp(28.0, 120.0);

    return Center(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: const CircleBorder(),
          padding: EdgeInsets.all(diameter * 0.16),
          minimumSize: Size(diameter, diameter),
        ),
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
      ),
    );
  }

  bool _isOperator(String s) {
    const ops = {'÷','×','-','+','=','AC','DEL','%','√','^','!','π','e'};
    const sci = {'sin','cos','tan','ln','log','sinh','cosh','tanh','sin⁻¹','cos⁻¹','tan⁻¹','x²','x³','xʸ','10ˣ','eˣ','Rand'};
    return ops.contains(s) || sci.contains(s);
  }
}

/// ---------------- BUTTON PRESS ROUTING ----------------
void _handlePress(String label, CalcNotifier notifier) {
  switch (label) {
    case 'AC':
      notifier.clear();
      return;
    case 'DEL':
      notifier.delete();
      return;
    case '=':
      notifier.evaluate();
      return;
    case 'π':
      notifier.append('π');
      return;
    case 'e':
      notifier.append('e');
      return;
    case '%':
      notifier.append('%');
      return;
    case 'Rand':
      notifier.append((math.Random().nextDouble() * 10).toStringAsFixed(6));
      return;
    case 'x²':
      notifier.append('^2');
      return;
    case 'x³':
      notifier.append('^3');
      return;
    case 'xʸ':
      notifier.append('^');
      return;
    case 'x!':
    case '!':
      notifier.append('!');
      return;
    case '√':
      notifier.append('√(');
      return;
    case '10ˣ':
      notifier.append('10^');
      return;
    case 'eˣ':
      notifier.append('e^');
      return;
  // scientific funcs append a "(" for user to fill
    case 'sin':
    case 'cos':
    case 'tan':
    case 'ln':
    case 'log':
    case 'sinh':
    case 'cosh':
    case 'tanh':
    case 'sin⁻¹':
    case 'cos⁻¹':
    case 'tan⁻¹':
      notifier.append('$label(');
      return;
    default:
      notifier.append(label);
  }
}
