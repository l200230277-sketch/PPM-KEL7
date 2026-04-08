import 'dart:typed_data';

import 'package:flutter/material.dart';

class DramaPoster extends StatelessWidget {
  const DramaPoster({
    super.key,
    required this.assetPath,
    this.imageBytes,
    this.height,
    this.width,
    this.borderRadius = 14,
    this.fit = BoxFit.cover,
  });

  final String assetPath;
  final Uint8List? imageBytes;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final Widget image = imageBytes != null
        ? Image.memory(
            imageBytes!,
            height: height,
            width: width,
            fit: fit,
          )
        : assetPath.isEmpty
            ? Container(
                height: height,
                width: width,
                color: const Color(0xFF8EB2B7),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.white54,
                  size: 40,
                ),
              )
            : Image.asset(
            assetPath,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                width: width,
                color: const Color(0xFF8EB2B7),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_rounded,
                  color: Colors.white70,
                  size: 34,
                ),
              );
            },
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }
}
