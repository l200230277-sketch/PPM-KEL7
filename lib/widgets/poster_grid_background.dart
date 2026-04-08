import 'package:flutter/material.dart';

class PosterGridBackground extends StatelessWidget {
  const PosterGridBackground({
    super.key,
    required this.child,
    this.bottomGradientStrength = 0.55,
  });

  final Widget child;
  final double bottomGradientStrength;

  static const Color _bg = Color(0xFF0D2B2C);

  static final List<_Tile> _tiles = [
    // Baris 1 — diagonal offset -0.04 per kolom
    _Tile(-0.06,  0.00, 0.26, 0.20, -0.22, 1),
    _Tile( 0.23, -0.04, 0.26, 0.20, -0.22, 2),
    _Tile( 0.52, -0.08, 0.26, 0.20, -0.22, 3),
    _Tile( 0.81, -0.12, 0.26, 0.20, -0.22, 4),

    // Baris 2
    _Tile(-0.06,  0.24, 0.26, 0.20, -0.22, 5),
    _Tile( 0.23,  0.20, 0.26, 0.20, -0.22, 6),
    _Tile( 0.52,  0.16, 0.26, 0.20, -0.22, 7),
    _Tile( 0.81,  0.12, 0.26, 0.20, -0.22, 8),

    // Baris 3
    _Tile(-0.06,  0.48, 0.26, 0.20, -0.22, 9),
    _Tile( 0.23,  0.44, 0.26, 0.20, -0.22, 10),
    _Tile( 0.52,  0.40, 0.26, 0.20, -0.22, 11),
    _Tile( 0.81,  0.36, 0.26, 0.20, -0.22, 4),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    for (final t in _tiles)
                      Positioned(
                        left: w * t.left,
                        top: h * t.top,
                        width: w * t.wFrac,
                        height: h * t.hFrac,
                        child: Transform.rotate(
                          angle: t.angle,
                          child: Opacity(
                            opacity: 0.85,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/${t.assetIndex}.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: const Color(0xFF1A4546),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Teal overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF0D2B2C).withValues(alpha: 0.45),
              ),
            ),
          ),

          // Gradient fade bawah
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _bg.withValues(alpha: 0.00),
                    _bg.withValues(alpha: 0.00),
                    _bg.withValues(alpha: 0.85),
                    _bg.withValues(alpha: 0.98),
                  ],
                  stops: const [0.0, 0.35, 0.62, 1.0],
                ),
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}

class _Tile {
  const _Tile(
    this.left,
    this.top,
    this.wFrac,
    this.hFrac,
    this.angle,
    this.assetIndex,
  );

  final double left;
  final double top;
  final double wFrac;
  final double hFrac;
  final double angle;
  final int assetIndex;
}