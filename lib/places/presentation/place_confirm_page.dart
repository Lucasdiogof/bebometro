import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../data/geo_search.dart';
import '../domain/geo_point.dart';
import '../domain/place.dart';
import '../domain/place_draft.dart';
import 'place_map.dart';

/// Shows the chosen result (or the device point) on the map so the person
/// can check it, adjust the point, give a nickname and decide whether to
/// keep it in the saved places. Pops with a [PlaceDraft].
class PlaceConfirmPage extends StatefulWidget {
  const PlaceConfirmPage({
    super.key,
    required this.draft,
    this.match,
    this.allowSave = true,
  });

  /// What was chosen: a search result or a bare point.
  final PlaceDraft draft;

  /// A saved place that already holds this provider result.
  final Place? match;

  /// False when editing a saved place (it is saved anyway).
  final bool allowSave;

  @override
  State<PlaceConfirmPage> createState() => _PlaceConfirmPageState();
}

class _PlaceConfirmPageState extends State<PlaceConfirmPage> {
  late GeoPoint? _point = widget.draft.point;
  late String? _name = widget.draft.providerName;
  late String? _address = widget.draft.address;
  late String? _city = widget.draft.city;
  late String? _state = widget.draft.state;
  late String? _provider = widget.draft.provider;
  late String? _placeId = widget.draft.providerPlaceId;
  late LocationSource? _source = widget.draft.source;
  late Place? _match = widget.match;
  late final _nickname = TextEditingController(
      text: widget.draft.nickname ?? widget.match?.nickname ?? '');
  late bool _save = widget.allowSave;

  /// Name of the establishment before the point was moved.
  String? _previousName;
  bool _adjusted = false;
  bool _tilesFailed = false;
  bool _reverseLoading = false;
  String? _reverseMessage;
  String? _error;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  void _moved(GeoPoint p) {
    setState(() {
      _point = p;
      if (!_adjusted) {
        _adjusted = true;
        // The establishment and its address belong to the old point: they are
        // no longer presented as this place.
        _previousName = _name;
        _name = null;
        _address = null;
        _city = null;
        _state = null;
        _provider = null;
        _placeId = null;
        _match = null;
      }
      _source = LocationSource.adjusted;
      _reverseMessage = null;
    });
  }

  Future<void> _lookUpAddress() async {
    final p = _point;
    if (p == null || _reverseLoading) return;
    setState(() {
      _reverseLoading = true;
      _reverseMessage = null;
    });
    try {
      final r = await getIt<GeoSearch>().reverse(p);
      if (!mounted || _point != p) return; // moved again meanwhile
      setState(() {
        _reverseLoading = false;
        if (r == null || r.address == null) {
          _reverseMessage = 'Nenhum endereço encontrado para este ponto.';
        } else {
          // Only the address: a name nearby may be another establishment.
          _address = r.name != null ? r.address : (r.address ?? r.line1);
          _city = r.city;
          _state = r.state;
        }
      });
    } on GeoSearchException catch (e) {
      if (!mounted) return;
      setState(() {
        _reverseLoading = false;
        _reverseMessage = e.error == GeoSearchError.offline
            ? 'Sem internet. O ponto continua marcado.'
            : 'Não foi possível buscar o endereço agora.';
      });
    }
  }

  void _use() {
    final nick = _nickname.text.trim();
    final saving = _match != null || (widget.allowSave && _save);
    final hasName = nick.isNotEmpty ||
        (_name?.isNotEmpty ?? false) ||
        (_address?.isNotEmpty ?? false);
    if (saving && !hasName) {
      setState(() => _error = 'Dê um apelido para salvar este ponto.');
      return;
    }
    Navigator.of(context).pop(PlaceDraft(
      saved: _match,
      nickname: nick.isEmpty ? null : nick,
      providerName: _name,
      address: _address,
      city: _city,
      state: _state,
      point: _point,
      source: _source,
      provider: _placeId == null ? null : _provider,
      providerPlaceId: _placeId,
      save: saving,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final point = _point;
    final showMap = point != null && PlaceMap.available && !_tilesFailed;
    final title = placeTitle(
        nickname: null,
        providerName: _name,
        address: _address,
        point: point,
        fallback: 'Local');
    final canReverse = point != null &&
        getIt<GeoSearch>().configured &&
        _name == null &&
        (_address == null || _adjusted);

    return Scaffold(
      appBar: AppBar(title: const Text('Conferir local')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
              children: [
                if (showMap) ...[
                  SizedBox(
                    height: (MediaQuery.sizeOf(context).height * 0.42)
                        .clamp(240.0, 420.0),
                    child: PlaceMap(
                      point: point,
                      onMoved: _moved,
                      onTilesFailed: () {
                        if (mounted) setState(() => _tilesFailed = true);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  const Text(
                    'Toque no mapa para ajustar o ponto, se precisar.',
                    style: AppText.caption,
                  ),
                ] else if (point != null && _tilesFailed)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpace.sm),
                    child: InfoPill(
                      'O mapa não carregou. Você pode confirmar pelos dados abaixo.',
                      icon: Icons.map_outlined,
                      warning: true,
                    ),
                  ),
                const SizedBox(height: AppSpace.md),
                SurfaceCard(
                  highlight: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.title),
                      if (_name != null && _address != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpace.xs),
                          child: Text(_address!, style: AppText.body),
                        ),
                      if (_name == null && _address == null && point != null)
                        const Padding(
                          padding: EdgeInsets.only(top: AppSpace.xs),
                          child: Text('Sem endereço confirmado para este ponto.',
                              style: AppText.caption),
                        ),
                      if (_adjusted)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpace.sm),
                          child: InfoPill(
                            _previousName != null
                                ? 'Ponto ajustado: "$_previousName" e o endereço '
                                    'dele não valem mais para este ponto.'
                                : 'Ponto ajustado por você.',
                            icon: Icons.edit_location_alt_outlined,
                          ),
                        ),
                      if (canReverse) ...[
                        const SizedBox(height: AppSpace.sm),
                        OutlinedButton.icon(
                          onPressed: _reverseLoading ? null : _lookUpAddress,
                          icon: _reverseLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.travel_explore_rounded),
                          label: const Text('Buscar endereço deste ponto'),
                        ),
                      ],
                      if (_reverseMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpace.xs),
                          child:
                              Text(_reverseMessage!, style: AppText.caption),
                        ),
                    ],
                  ),
                ),
                if (_match != null) ...[
                  const SizedBox(height: AppSpace.md),
                  InfoPill(
                    'Você já salvou este lugar como "${_match!.displayName}". '
                    'Ele será reaproveitado${_match!.nickname != null ? ' e o apelido continua' : ''}.',
                    icon: Icons.bookmark_rounded,
                  ),
                ],
                const SectionTitle('Apelido (opcional)'),
                TextField(
                  controller: _nickname,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() => _error = null),
                  decoration: InputDecoration(
                    hintText: 'Ex.: Casa da Samara',
                    helperText: 'Aparece no lugar do nome. O endereço fica nos detalhes.',
                    errorText: _error,
                  ),
                ),
                if (_previousName != null &&
                    _nickname.text.trim().isEmpty) ...[
                  const SizedBox(height: AppSpace.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      avatar: const Icon(Icons.label_outline_rounded,
                          size: 18, color: AppColors.amber),
                      label: Text('Usar "$_previousName" como apelido'),
                      onPressed: () => setState(() {
                        _nickname.text = _previousName!;
                        _error = null;
                      }),
                    ),
                  ),
                ],
                if (widget.allowSave && _match == null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Salvar nos meus locais'),
                    subtitle: const Text(
                        'Para escolher de novo nos próximos rolês. Fica privado.'),
                    value: _save,
                    activeThumbColor: AppColors.amber,
                    onChanged: (v) => setState(() {
                      _save = v;
                      _error = null;
                    }),
                  ),
                if (_name != null || _address != null) ...[
                  const SizedBox(height: AppSpace.sm),
                  const MapAttribution(compact: true),
                ],
              ],
            ),
          ),
          BottomActionBar(
            child: FilledButton.icon(
              onPressed: _use,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Usar este local'),
            ),
          ),
        ],
      ),
    );
  }
}
