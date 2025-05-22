import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

import 'animation_loading.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.isOnline = true,
    required this.localPathOrUrl,
    this.width,
    this.height,
    this.boxFit,
    this.errorWidget,
    this.placeholder,
    this.alignment,
  });

  final bool isOnline;

  /// Widget placeholder while image downloading from server
  final Widget? placeholder;

  /// localPathOrUrl is local path on offline mode, url on online mode
  final String? localPathOrUrl;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final BoxFit? boxFit;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    if (isNullOrEmpty(localPathOrUrl)) {
      return errorWidget ?? const SizedBox.shrink();
    }
    return isOnline
        ? CachedNetworkImage(
            imageUrl: localPathOrUrl ?? '',
            alignment: alignment ?? Alignment.center,
            placeholder: (context, url) =>
                placeholder ?? const AnimationLoading(strokeWidth: 1, size: 25),
            errorWidget: (context, url, error) =>
                errorWidget ?? const SizedBox.shrink(),
            width: width,
            height: height,
            fit: boxFit,
          )
        : Image.file(
            File(localPathOrUrl ?? ''),
            alignment: alignment ?? Alignment.center,
            errorBuilder: (context, error, stackTrace) =>
                errorWidget ?? const SizedBox.shrink(),
            width: width,
            height: height,
            fit: boxFit,
          );
  }
}
