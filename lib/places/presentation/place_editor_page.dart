import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../outings/domain/outing.dart';
import '../../outings/presentation/outing_type_picker.dart';
import '../data/place_repository.dart';
import '../domain/geo_point.dart';
import '../domain/place.dart';
import 'place_picker_page.dart';
import '../../l10n/l10n.dart';

/// Creates or edits a saved place. Editing never rewrites the place data kept
/// inside past outings.
class PlaceEditorPage extends StatefulWidget {
  const PlaceEditorPage({super.key, this.editing});

  final Place? editing;

  @override
  State<PlaceEditorPage> createState() => _PlaceEditorPageState();
}

class _PlaceEditorPageState extends State<PlaceEditorPage> {
  late final TextEditingController _nickname;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late OutingType _type;

  // Location kept with the place (from a search, the device or the map).
  String? _providerName;
  GeoPoint? _point;
  LocationSource? _source;
  String? _provider;
  String? _providerPlaceId;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.editing;
    _nickname = TextEditingController(text: p?.nickname ?? '');
    _address = TextEditingController(text: p?.address ?? '');
    _city = TextEditingController(text: p?.city ?? '');
    _state = TextEditingController(text: p?.state ?? '');
    _type = p?.type ?? OutingType.bar;
    _providerName = p?.providerName;
    _point = p?.point;
    _source = p?.source;
    _provider = p?.provider;
    _providerPlaceId = p?.providerPlaceId;
  }

  Future<void> _locate() async {
    final d = await PlacePickerPage.open(
      context,
      mode: PlacePickerMode.locate,
      type: _type,
      editing: widget.editing,
    );
    if (d == null || !mounted) return;
    setState(() {
      _providerName = d.providerName;
      _point = d.point;
      _source = d.source;
      _provider = d.provider;
      _providerPlaceId = d.providerPlaceId;
      _address.text = d.address ?? '';
      _city.text = d.city ?? '';
      _state.text = d.state ?? '';
      // The nickname the person chose is never overwritten by the search.
      if (_nickname.text.trim().isEmpty && d.nickname != null) {
        _nickname.text = d.nickname!;
      }
      _error = null;
    });
  }

  void _clearLocation() => setState(() {
    _providerName = null;
    _point = null;
    _source = null;
    _provider = null;
    _providerPlaceId = null;
  });

  @override
  void dispose() {
    _nickname.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final place = await getIt<PlaceRepository>().save(
        id: widget.editing?.id,
        type: _type,
        nickname: _nickname.text,
        address: _address.text,
        city: _city.text,
        state: _state.text,
        providerName: _providerName,
        point: _point,
        source: _source,
        provider: _provider,
        providerPlaceId: _providerPlaceId,
      );
      if (mounted) Navigator.of(context).pop(place);
    } on ArgumentError catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = '${e.message}';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        showToast(context, tr.customSaveFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? tr.placeEditTitle : tr.placesNew)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter,
                0,
                AppSpace.gutter,
                AppSpace.xl,
              ),
              children: [
                if (editing) Text(tr.placeEditorNote, style: AppText.caption),
                SectionTitle(tr.customType),
                OutingTypePicker(
                  selected: _type,
                  onSelected: (t) => setState(() => _type = t),
                ),
                SectionTitle(tr.customIdentification),
                TextField(
                  controller: _nickname,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: tr.pickerManualNickname,
                    hintText: tr.startNicknameHint,
                    errorText: _error,
                  ),
                ),
                SectionTitle(tr.placeEditorLocation),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _point != null
                                ? Icons.location_on_rounded
                                : Icons.location_off_outlined,
                            color: _point != null
                                ? AppColors.amber
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _providerName ??
                                      (_point != null
                                          ? tr.placePointOnMap
                                          : tr.placeEditorNoPoint),
                                  style: AppText.subtitle,
                                ),
                                Text(switch (_source) {
                                  LocationSource.search =>
                                    tr.placeEditorSourceSearch,
                                  LocationSource.currentLocation =>
                                    tr.placeSourceLocation,
                                  LocationSource.adjusted =>
                                    tr.placeEditorSourceAdjusted,
                                  null =>
                                    _point == null
                                        ? tr.placeEditorNoPointHint
                                        : tr.placeEditorPointSaved,
                                }, style: AppText.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.sm,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _locate,
                            icon: const Icon(Icons.search_rounded),
                            label: Text(
                              _point == null
                                  ? tr.placeEditorSearchMap
                                  : tr.placeEditorSearchAdjust,
                            ),
                          ),
                          if (_point != null || _providerName != null)
                            TextButton(
                              onPressed: _clearLocation,
                              child: Text(tr.placeEditorRemoveFromMap),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                TextField(
                  controller: _address,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: tr.startAddressLabel,
                    helperText: tr.placeEditorAddressHelper,
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _city,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: tr.startCityLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: TextField(
                        controller: _state,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 2,
                        decoration: InputDecoration(
                          labelText: tr.startStateLabel,
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        tr.placeEditorPrivate,
                        style: AppText.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BottomActionBar(
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(editing ? tr.entrySaveChanges : tr.placeEditorSave),
            ),
          ),
        ],
      ),
    );
  }
}
