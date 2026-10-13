import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../outings/domain/outing.dart';
import '../../outings/presentation/outing_type_picker.dart';
import '../data/place_repository.dart';
import '../domain/place.dart';

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
  }

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
        showToast(context, 'Não foi possível salvar. Seus dados continuam aqui.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar local' : 'Novo local')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
              children: [
                if (editing)
                  const Text(
                    'As mudanças valem para os próximos rolês. Os rolês que '
                    'já aconteceram mantêm o nome e o endereço de quando '
                    'foram feitos.',
                    style: AppText.caption,
                  ),
                const SectionTitle('Tipo'),
                OutingTypePicker(
                  selected: _type,
                  onSelected: (t) => setState(() => _type = t),
                ),
                const SectionTitle('Identificação'),
                TextField(
                  controller: _nickname,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Apelido',
                    hintText: 'Ex.: Bar MELT, Casa da Samara',
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                TextField(
                  controller: _address,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Endereço (opcional)',
                    helperText: 'Apelido ou endereço já bastam.',
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
                        decoration: const InputDecoration(
                            labelText: 'Cidade (opcional)'),
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: TextField(
                        controller: _state,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 2,
                        decoration: const InputDecoration(
                            labelText: 'UF', counterText: ''),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.lg),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 16, color: AppColors.textMuted),
                    SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        'Seus locais e endereços são privados: só aparecem '
                        'para você.',
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
              child: Text(editing ? 'Salvar alterações' : 'Salvar local'),
            ),
          ),
        ],
      ),
    );
  }
}
