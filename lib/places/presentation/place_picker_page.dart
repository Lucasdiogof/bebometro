import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../data/device_location.dart';
import '../data/geo_search.dart';
import '../data/place_repository.dart';
import '../domain/geo_point.dart';
import '../domain/place.dart';
import '../domain/place_draft.dart';
import 'place_confirm_page.dart';
import 'place_map.dart';
import '../../l10n/l10n.dart';
import '../../core/utils/formatters.dart';

enum PlacePickerMode {
  /// Choosing the place of a new outing.
  start,

  /// Correcting the place of one outing.
  change,

  /// Finding the location of a saved place being edited: no saved list, no
  /// "nickname only" (the editor already has the nickname).
  locate,
}

/// Reusable place picker: search (establishments and addresses), saved
/// favourites and recents, "Usar minha localização" and "nickname only".
/// Pops with a [PlaceDraft], or null when the person backs out.
///
/// The device location is read only after its button is tapped; typing an
/// address never asks for any permission.
class PlacePickerPage extends StatefulWidget {
  const PlacePickerPage({
    super.key,
    this.mode = PlacePickerMode.start,
    this.type = OutingType.bar,
    this.editing,
  });

  final PlacePickerMode mode;
  final OutingType type;

  /// The saved place being edited ([PlacePickerMode.locate]).
  final Place? editing;

  static Future<PlaceDraft?> open(
    BuildContext context, {
    PlacePickerMode mode = PlacePickerMode.start,
    OutingType type = OutingType.bar,
    Place? editing,
  }) => Navigator.of(context).push<PlaceDraft>(
    MaterialPageRoute(
      builder: (_) => PlacePickerPage(mode: mode, type: type, editing: editing),
    ),
  );

  @override
  State<PlacePickerPage> createState() => _PlacePickerPageState();
}

class _PlacePickerPageState extends State<PlacePickerPage> {
  final _query = TextEditingController();
  final _search = getIt<GeoSearch>();
  final _places = getIt<PlaceRepository>();
  Timer? _debounce;

  /// Answers to older keystrokes are dropped by comparing this number.
  int _seq = 0;
  String _lastSent = '';
  bool _loading = false;
  GeoSearchError? _error;
  List<GeoResult> _results = const [];

  GeoPoint? _near;
  bool _approximate = false;
  bool _locating = false;
  LocationProblem? _locationProblem;
  bool _nearbyLoading = false;
  GeoSearchError? _nearbyError;
  List<GeoResult>? _nearby;

  bool get _locate => widget.mode == PlacePickerMode.locate;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    final q = text.trim();
    setState(() {}); // saved-place filter and states follow the text
    if (q.length < GeoSearch.minChars || !_search.configured) {
      _seq++;
      setState(() {
        _loading = false;
        _error = null;
        _results = const [];
        _lastSent = '';
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _run(q));
  }

  Future<void> _run(String q, {bool force = false}) async {
    if (!force && q == _lastSent && _error == null) return; // same call
    final seq = ++_seq;
    _lastSent = q;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _search.autocomplete(q, near: _near);
      if (!mounted || seq != _seq) return;
      setState(() {
        _loading = false;
        _results = list;
      });
    } on GeoSearchException catch (e) {
      if (!mounted || seq != _seq) return;
      setState(() {
        _loading = false;
        _error = e.error;
        _results = const [];
      });
    }
  }

  Future<void> _useLocation() async {
    if (_locating) return;
    setState(() {
      _locating = true;
      _locationProblem = null;
    });
    final r = await getIt<DeviceLocation>().current();
    if (!mounted) return;
    setState(() {
      _locating = false;
      _locationProblem = r.problem;
      _near = r.point ?? _near;
      _approximate = r.approximate;
    });
    final point = r.point;
    if (point == null) return;
    if (!_search.configured) {
      // No search provider: the point itself can still be confirmed.
      await _confirmPoint(point);
      return;
    }
    setState(() {
      _nearbyLoading = true;
      _nearbyError = null;
    });
    try {
      final list = await _search.nearby(
        point,
        radiusMeters: r.approximate ? 1500 : 300,
      );
      if (!mounted) return;
      setState(() {
        _nearbyLoading = false;
        _nearby = list;
      });
    } on GeoSearchException catch (e) {
      if (!mounted) return;
      setState(() {
        _nearbyLoading = false;
        _nearbyError = e.error;
        _nearby = const [];
      });
    }
  }

  Future<void> _chooseResult(GeoResult r) async {
    var match = _places.findByProvider(GeoSearch.provider, r.placeId);
    if (_locate) {
      if (match != null && match.id != widget.editing?.id) {
        final go = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(tr.pickerAlreadySavedTitle),
            content: Text(tr.pickerAlreadySavedBody(match!.displayName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr.pickerUseAnyway),
              ),
            ],
          ),
        );
        if (go != true || !mounted) return;
      }
      match = null; // the editor keeps editing its own place
    }
    final draft = PlaceDraft(
      providerName: r.name,
      address: r.address,
      city: r.city,
      state: r.state,
      point: r.point,
      source: LocationSource.search,
      provider: r.placeId == null ? null : GeoSearch.provider,
      providerPlaceId: r.placeId,
    );
    await _confirm(draft, match: match);
  }

  Future<void> _confirmPoint(GeoPoint p) =>
      _confirm(PlaceDraft(point: p, source: LocationSource.currentLocation));

  Future<void> _confirm(PlaceDraft draft, {Place? match}) async {
    final result = await Navigator.of(context).push<PlaceDraft>(
      MaterialPageRoute(
        builder: (_) =>
            PlaceConfirmPage(draft: draft, match: match, allowSave: !_locate),
      ),
    );
    if (result != null && mounted) Navigator.of(context).pop(result);
  }

  void _chooseSaved(Place p) => Navigator.of(context).pop(PlaceDraft.saved(p));

  Future<void> _nicknameOnly() async {
    final result = await Navigator.of(context).push<PlaceDraft>(
      MaterialPageRoute(builder: (_) => const _ManualPlacePage()),
    );
    if (result != null && mounted) Navigator.of(context).pop(result);
  }

  List<Place> _savedMatching(String q) {
    final needle = q.toLowerCase();
    return [
      for (final p in _places.active())
        if ([
          p.nickname,
          p.providerName,
          p.address,
        ].any((v) => v != null && v.toLowerCase().contains(needle)))
          p,
    ].take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim();
    final typing = q.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (widget.mode) {
          PlacePickerMode.start => tr.pickerStartTitle,
          PlacePickerMode.change => tr.pickerChangeTitle,
          PlacePickerMode.locate => tr.pickerLocateTitle,
        }),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter,
                AppSpace.sm,
                AppSpace.gutter,
                AppSpace.sm,
              ),
              child: TextField(
                controller: _query,
                autofocus: false,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.words,
                onChanged: _onChanged,
                onSubmitted: (v) {
                  final t = v.trim();
                  if (t.length >= GeoSearch.minChars && _search.configured) {
                    _debounce?.cancel();
                    _run(t);
                  }
                },
                decoration: InputDecoration(
                  hintText: tr.pickerSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: typing
                      ? IconButton(
                          tooltip: tr.pickerClearSearch,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _query.clear();
                            _onChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  0,
                  AppSpace.gutter,
                  AppSpace.xl,
                ),
                children: typing ? _typingChildren(q) : _idleChildren(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _idleChildren() {
    final saved = _locate ? const <Place>[] : _savedShortcuts();
    return [
      _ActionTile(
        icon: Icons.my_location_rounded,
        title: tr.pickerUseLocation,
        subtitle: _approximate && _near != null
            ? tr.pickerApproximate
            : tr.pickerLocationHint,
        busy: _locating,
        onTap: _useLocation,
      ),
      if (_locationProblem != null) _locationProblemCard(_locationProblem!),
      if (!_locate)
        _ActionTile(
          icon: Icons.edit_note_rounded,
          title: tr.pickerNicknameOnly,
          subtitle: tr.pickerNicknameOnlyExample,
          onTap: _nicknameOnly,
        ),
      if (_near != null) ..._nearbySection(),
      if (saved.isNotEmpty) ...[
        SectionTitle(tr.pickerYourPlaces),
        for (final p in saved)
          _SavedTile(place: p, onTap: () => _chooseSaved(p)),
      ],
      if (!_search.configured) ...[
        const SizedBox(height: AppSpace.lg),
        _Notice(
          icon: Icons.search_off_rounded,
          text: tr.pickerNotConfiguredFull,
        ),
      ],
    ];
  }

  List<Place> _savedShortcuts() {
    final favorites = _places.active().where((p) => p.favorite);
    final recent = _places.recent(getIt<OutingRepository>().all(), limit: 6);
    final seen = <String>{};
    return [
      for (final p in [...favorites, ...recent])
        if (seen.add(p.id)) p,
    ];
  }

  List<Widget> _nearbySection() {
    final list = _nearby;
    return [
      SectionTitle(tr.pickerNearYou),
      if (_nearbyLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpace.md),
          child: LinearProgressIndicator(minHeight: 2),
        )
      else if (_nearbyError != null)
        _Notice(icon: Icons.wifi_off_rounded, text: _errorText(_nearbyError!))
      else if (list != null && list.isEmpty)
        _Notice(
          icon: Icons.location_searching_rounded,
          text: tr.pickerNothingNearby,
        )
      else if (list != null)
        for (final r in list.take(10))
          _ResultTile(result: r, onTap: () => _chooseResult(r)),
      _ActionTile(
        icon: Icons.push_pin_outlined,
        title: tr.pickerPinOnly,
        subtitle: tr.pickerPinOnlyHint,
        onTap: () => _confirmPoint(_near!),
      ),
      if (list != null && list.isNotEmpty) const MapAttribution(compact: true),
    ];
  }

  List<Widget> _typingChildren(String q) {
    final saved = _locate ? const <Place>[] : _savedMatching(q);
    final children = <Widget>[];
    if (saved.isNotEmpty) {
      children
        ..add(SectionTitle(tr.pickerYourPlaces))
        ..addAll([
          for (final p in saved)
            _SavedTile(place: p, onTap: () => _chooseSaved(p)),
        ]);
    }
    if (!_search.configured) {
      children.add(
        _Notice(icon: Icons.search_off_rounded, text: tr.pickerNotConfigured),
      );
    } else if (q.length < GeoSearch.minChars) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
          child: Text(tr.pickerMinChars, style: AppText.caption),
        ),
      );
    } else if (_error != null) {
      children.add(
        _Notice(
          icon: _error == GeoSearchError.offline
              ? Icons.wifi_off_rounded
              : Icons.cloud_off_rounded,
          text: _errorText(_error!),
          action: tr.commonRetry,
          onAction: () => _run(q, force: true),
        ),
      );
    } else if (!_loading && _lastSent == q && _results.isEmpty) {
      children.add(
        _Notice(icon: Icons.search_off_rounded, text: tr.pickerNothingFound),
      );
    } else if (_results.isNotEmpty) {
      children
        ..add(SectionTitle(tr.pickerResults))
        ..addAll([
          for (final r in _results)
            _ResultTile(
              result: r,
              savedAs: _places
                  .findByProvider(GeoSearch.provider, r.placeId)
                  ?.displayName,
              onTap: () => _chooseResult(r),
            ),
        ])
        ..add(const MapAttribution(compact: true));
    }
    if (!_locate) {
      children.add(
        _ActionTile(
          icon: Icons.edit_note_rounded,
          title: tr.pickerNicknameOnly,
          subtitle: tr.pickerNicknameOnlyShort,
          onTap: _nicknameOnly,
        ),
      );
    }
    return children;
  }

  String _errorText(GeoSearchError e) => switch (e) {
    GeoSearchError.offline => tr.pickerErrorOffline,
    GeoSearchError.unavailable => tr.pickerErrorUnavailable,
    GeoSearchError.notConfigured => tr.pickerNotConfigured,
  };

  Widget _locationProblemCard(LocationProblem p) {
    final location = getIt<DeviceLocation>();
    return switch (p) {
      LocationProblem.serviceOff => _Notice(
        icon: Icons.location_disabled_rounded,
        text: tr.pickerLocServiceOff,
        action: tr.pickerOpenSettings,
        onAction: location.openLocationSettings,
      ),
      LocationProblem.denied => _Notice(
        icon: Icons.location_off_rounded,
        text: tr.pickerLocDenied,
      ),
      LocationProblem.deniedForever => _Notice(
        icon: Icons.location_off_rounded,
        text: tr.pickerLocDeniedForever,
        action: tr.pickerOpenSettings,
        onAction: location.openAppSettings,
      ),
      LocationProblem.timeout => _Notice(
        icon: Icons.timer_off_outlined,
        text: tr.pickerLocTimeout,
        action: tr.commonRetry,
        onAction: _useLocation,
      ),
      LocationProblem.unavailable => _Notice(
        icon: Icons.location_off_rounded,
        text: tr.pickerLocUnavailable,
      ),
    };
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: SurfaceCard(
        onTap: busy ? null : onTap,
        child: Row(
          children: [
            busy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, color: AppColors.amber),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.subtitle),
                  Text(subtitle, style: AppText.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedTile extends StatelessWidget {
  const _SavedTile({required this.place, required this.onTap});

  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sub = [
      place.providerSubtitle,
      place.subtitleAddress,
      place.cityState,
    ].whereType<String>().join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: SurfaceCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              place.favorite ? Icons.star_rounded : place.type.icon,
              color: AppColors.amber,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subtitle,
                  ),
                  if (sub.isNotEmpty)
                    Text(
                      sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.onTap, this.savedAs});

  final GeoResult result;
  final VoidCallback onTap;

  /// Display name of the saved place that already holds this result.
  final String? savedAs;

  @override
  Widget build(BuildContext context) {
    final d = result.distanceMeters;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: SurfaceCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              result.name != null
                  ? Icons.storefront_rounded
                  : Icons.place_outlined,
              color: AppColors.amber,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subtitle,
                  ),
                  if (result.subtitle != null)
                    Text(
                      result.subtitle!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption,
                    ),
                  if (savedAs != null || d != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.xs),
                      child: Text(
                        [
                          if (d != null) formatDistance(d),
                          if (savedAs != null) tr.pickerSavedAs(savedAs!),
                        ].join(' · '),
                        style: AppText.caption.copyWith(color: AppColors.amber),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.text,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: SurfaceCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textMuted),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: AppText.body),
                  if (action != null && onAction != null)
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: onAction,
                      child: Text(action!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nickname (enough alone) with an optional typed address. City and state are
/// never filled in by guess.
class _ManualPlacePage extends StatefulWidget {
  const _ManualPlacePage();

  @override
  State<_ManualPlacePage> createState() => _ManualPlacePageState();
}

class _ManualPlacePageState extends State<_ManualPlacePage> {
  final _nickname = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  bool _save = true;
  bool _showAddress = false;
  String? _error;
  String? _stateError;

  @override
  void dispose() {
    _nickname.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    super.dispose();
  }

  void _done() {
    String? clean(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final nick = clean(_nickname);
    final addr = clean(_address);
    final uf = clean(_state)?.toUpperCase();
    setState(() {
      _error = nick == null && addr == null
          ? tr.pickerNeedNicknameOrAddress
          : null;
      _stateError = uf != null && !RegExp(r'^[A-Z]{2}$').hasMatch(uf)
          ? tr.pickerStateTwoLetters
          : null;
    });
    if (_error != null || _stateError != null) return;
    Navigator.of(context).pop(
      PlaceDraft(
        nickname: nick,
        address: addr,
        city: clean(_city),
        state: uf,
        save: _save,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr.startNicknameLabel)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter,
                AppSpace.sm,
                AppSpace.gutter,
                AppSpace.xl,
              ),
              children: [
                TextField(
                  controller: _nickname,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _done(),
                  decoration: InputDecoration(
                    labelText: tr.pickerManualNickname,
                    hintText: tr.pickerManualHint,
                    helperText: tr.pickerManualHelper,
                    errorText: _error,
                  ),
                ),
                if (!_showAddress)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showAddress = true),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(tr.pickerAddAddress),
                    ),
                  )
                else ...[
                  const SizedBox(height: AppSpace.md),
                  TextField(
                    controller: _address,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: tr.startAddressLabel,
                      hintText: tr.startAddressHint,
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
                            errorText: _stateError,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr.placeSaveToMine),
                  subtitle: Text(tr.placeSaveToMineHint),
                  value: _save,
                  activeThumbColor: AppColors.amber,
                  onChanged: (v) => setState(() => _save = v),
                ),
              ],
            ),
          ),
          BottomActionBar(
            child: FilledButton(
              onPressed: _done,
              child: Text(tr.pickerUseThisPlace),
            ),
          ),
        ],
      ),
    );
  }
}
