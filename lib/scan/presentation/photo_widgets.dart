import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../outing_drinks/data/outing_drink_repository.dart';

/// Square thumbnail of an outing photo. When the file is gone (or the web
/// session ended) it shows a quiet placeholder: the text history is intact.
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({
    super.key,
    required this.photoId,
    this.size = 72,
    this.onTap,
  });

  final String photoId;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final repo = getIt<OutingDrinkRepository>();
    return Semantics(
      button: onTap != null,
      label: 'Foto',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            width: size,
            height: size,
            child: FutureBuilder<Uint8List?>(
              future: repo.photoBytes(photoId),
              builder: (context, snap) {
                final bytes = snap.data;
                if (bytes != null) {
                  return Image.memory(bytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (_, _, _) => _placeholder());
                }
                return _placeholder(
                    loading: snap.connectionState != ConnectionState.done);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder({bool loading = false}) => ColoredBox(
        color: AppColors.surfaceHigh,
        child: Center(
          child: Icon(
            loading ? Icons.image_outlined : Icons.image_not_supported_outlined,
            color: AppColors.textMuted,
          ),
        ),
      );
}

/// Full-screen view of a photo, with an optional delete that keeps the
/// confirmed drink data.
Future<void> showPhotoViewer(
  BuildContext context, {
  required String photoId,
  Future<void> Function()? onDelete,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(children: [
        Positioned.fill(
          child: FutureBuilder<Uint8List?>(
            future: getIt<OutingDrinkRepository>().photoBytes(photoId),
            builder: (context, snap) {
              final bytes = snap.data;
              if (bytes == null) {
                return const Center(
                  child: Text(
                      'Foto indisponível agora: ainda não enviada pelo outro '
                      'aparelho, ou sem conexão. O registro continua salvo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted)),
                );
              }
              return InteractiveViewer(
                maxScale: 5,
                child: Center(child: Image.memory(bytes)),
              );
            },
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (onDelete != null)
                IconButton(
                  tooltip: 'Excluir foto',
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: ctx,
                      builder: (c) => AlertDialog(
                        title: const Text('Excluir esta foto?'),
                        content: const Text(
                            'Só a foto sai. As bebidas e os dados que você '
                            'confirmou continuam no rolê.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Excluir',
                                  style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await onDelete();
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger),
                ),
              IconButton(
                tooltip: 'Fechar',
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ]),
          ),
        ),
      ]),
    ),
  );
}
