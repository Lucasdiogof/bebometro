import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../data/geo_search.dart';
import '../domain/geo_point.dart';
import 'open_in_maps.dart';

/// The map used to confirm and show a place. Only exists while its screen is
/// open (never on the home nor during the whole outing). Without a key it is
/// not built at all; if tiles fail, [onTilesFailed] lets the screen fall back
/// to the text data.
class PlaceMap extends StatefulWidget {
  const PlaceMap({
    super.key,
    required this.point,
    this.onMoved,
    this.onTilesFailed,
    this.interactive = true,
  });

  final GeoPoint point;

  /// Called when the person taps another spot (only when [interactive]).
  final ValueChanged<GeoPoint>? onMoved;
  final VoidCallback? onTilesFailed;
  final bool interactive;

  static bool get available => getIt<GeoSearch>().configured;

  @override
  State<PlaceMap> createState() => _PlaceMapState();
}

class _PlaceMapState extends State<PlaceMap> {
  final _controller = MapController();
  bool _reported = false;

  LatLng get _center => LatLng(widget.point.lat, widget.point.lng);

  @override
  void didUpdateWidget(PlaceMap old) {
    super.didUpdateWidget(old);
    if (old.point != widget.point) {
      try {
        _controller.move(_center, _controller.camera.zoom);
      } catch (_) {}
    }
  }

  void _zoom(double by) {
    try {
      final cam = _controller.camera;
      _controller.move(cam.center, (cam.zoom + by).clamp(3, 19));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final template = getIt<GeoSearch>().tileUrlTemplate;
    if (template == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        children: [
          Semantics(
            label: 'Mapa com o ponto do local',
            child: FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 17,
                minZoom: 3,
                maxZoom: 19,
                backgroundColor: AppColors.surface,
                interactionOptions: InteractionOptions(
                  flags: widget.interactive
                      ? InteractiveFlag.all & ~InteractiveFlag.rotate
                      : InteractiveFlag.none,
                ),
                onTap: widget.interactive && widget.onMoved != null
                    ? (_, latLng) {
                        final p = GeoPoint.tryCreate(
                            latLng.latitude, latLng.longitude);
                        if (p != null) widget.onMoved!(p);
                      }
                    : null,
              ),
              children: [
                TileLayer(
                  urlTemplate: template,
                  userAgentPackageName: 'com.lucksrei.bebometro',
                  retinaMode: RetinaMode.isHighDensity(context),
                  maxNativeZoom: 19,
                  errorTileCallback: (tile, error, stack) {
                    if (_reported) return;
                    _reported = true;
                    widget.onTilesFailed?.call();
                  },
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: _center,
                    width: 44,
                    height: 44,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on_rounded,
                        size: 44, color: AppColors.amber),
                  ),
                ]),
              ],
            ),
          ),
          if (widget.interactive)
            Positioned(
              right: AppSpace.sm,
              top: AppSpace.sm,
              child: Column(children: [
                _MapButton(
                    icon: Icons.add_rounded,
                    label: 'Aproximar',
                    onTap: () => _zoom(1)),
                const SizedBox(height: AppSpace.sm),
                _MapButton(
                    icon: Icons.remove_rounded,
                    label: 'Afastar',
                    onTap: () => _zoom(-1)),
                const SizedBox(height: AppSpace.sm),
                _MapButton(
                    icon: Icons.my_location_rounded,
                    label: 'Centralizar no ponto',
                    onTap: () => _controller.move(_center, 17)),
              ]),
            ),
          const Positioned(left: 0, right: 0, bottom: 0, child: MapAttribution()),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: label,
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.text),
        constraints:
            const BoxConstraints.tightFor(width: kTouchTarget, height: kTouchTarget),
      ),
    );
  }
}

/// Required credits for the search results and tiles (Geoapify free plan and
/// OpenStreetMap data).
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 11, color: AppColors.textMuted);
    Widget link(String text, String url) => InkWell(
          onTap: () => openLink(url),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Text(text,
                style: style.copyWith(decoration: TextDecoration.underline)),
          ),
        );
    return Container(
      color: compact ? null : AppColors.background.withValues(alpha: 0.75),
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
      child: Wrap(
        alignment: compact ? WrapAlignment.start : WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpace.xs,
        children: [
          link('Powered by Geoapify', 'https://www.geoapify.com/'),
          const Text('·', style: style),
          link('© OpenStreetMap', 'https://www.openstreetmap.org/copyright'),
          const Text('·', style: style),
          link('© OpenMapTiles', 'https://openmaptiles.org/'),
        ],
      ),
    );
  }
}
