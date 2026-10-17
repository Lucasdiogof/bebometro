import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/widgets/common.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../data/place_repository.dart';
import 'open_in_maps.dart';
import 'place_picker_page.dart';
import '../../l10n/l10n.dart';

/// Explicit correction of the place of ONE outing. Only that outing's copy
/// changes; its drinks, photos, outing-only items and tab stay on the same
/// outing id. The lock-screen tracking follows from the outing change (and
/// still shows only the name, never the address).
Future<void> changeOutingPlace(BuildContext context, Outing outing) async {
  final draft = await PlacePickerPage.open(
    context,
    mode: PlacePickerMode.change,
    type: outing.type,
  );
  if (draft == null || !context.mounted) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr.changePlaceTitle),
      content: Text(tr.changePlaceBody(draft.title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(tr.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(tr.changePlaceConfirm),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    final snapshot = await getIt<PlaceRepository>().resolve(draft, outing.type);
    await getIt<OutingRepository>().changePlace(outing.id, snapshot);
    if (context.mounted) showToast(context, tr.changePlaceDone);
  } catch (_) {
    if (context.mounted) {
      showToast(context, tr.changePlaceFailed);
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
    showToast(context, tr.openMapsFailed);
  }
}

/// Whether there is something geographic to open (never just a nickname).
bool outingHasMapTarget(Outing o) =>
    o.point != null || (o.address?.trim().isNotEmpty ?? false);
