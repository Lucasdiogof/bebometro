import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/widgets/common.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../data/place_repository.dart';
import 'open_in_maps.dart';
import 'place_picker_page.dart';

/// Explicit correction of the place of ONE outing. Only that outing's copy
/// changes; its drinks, photos, outing-only items and tab stay on the same
/// outing id. The lock-screen tracking follows from the outing change (and
/// still shows only the name, never the address).
Future<void> changeOutingPlace(BuildContext context, Outing outing) async {
  final draft = await PlacePickerPage.open(context,
      mode: PlacePickerMode.change, type: outing.type);
  if (draft == null || !context.mounted) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Trocar o local deste rolê?'),
      content: Text(
        'O rolê passa a ser "${draft.title}". Só este rolê muda: as bebidas, '
        'fotos e a comanda continuam nele, e os outros rolês não são '
        'alterados.',
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Trocar local')),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    final snapshot = await getIt<PlaceRepository>().resolve(draft, outing.type);
    await getIt<OutingRepository>().changePlace(outing.id, snapshot);
    if (context.mounted) showToast(context, 'Local do rolê atualizado');
  } catch (_) {
    if (context.mounted) {
      showToast(context, 'Não foi possível trocar o local. Nada foi alterado.');
    }
  }
}

/// "Abrir no mapa" for an outing's own copy of the place.
Future<void> openOutingInMaps(BuildContext context, Outing outing) async {
  final opened = await openInMaps(
    point: outing.point,
    address: outing.address,
    city: outing.city,
    state: outing.state,
    label: outing.placeName,
  );
  if (!opened && context.mounted) {
    showToast(context, 'Não foi possível abrir um aplicativo de mapas.');
  }
}

/// Whether there is something geographic to open (never just a nickname).
bool outingHasMapTarget(Outing o) =>
    o.point != null || (o.address?.trim().isNotEmpty ?? false);
