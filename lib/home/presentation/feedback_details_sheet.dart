import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../../l10n/l10n.dart';

/// What the person chose in the details sheet.
enum FeedbackDetailsResult { saved, review, skipped }

/// Optional follow-up to the quick feedback: how they woke up, hangover and a
/// free note, plus a shortcut to review forgotten drinks. Nothing is
/// mandatory and nothing here measures consumption.
///
/// With [editMood] the sheet also lets the person change the quick answer
/// (used when editing the account later from the outing's detail).
Future<FeedbackDetailsResult?> showFeedbackDetails(
  BuildContext context,
  String outingId, {
  bool editMood = false,
}) {
  return showModalBottomSheet<FeedbackDetailsResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FeedbackDetails(outingId: outingId, editMood: editMood),
  );
}

class _FeedbackDetails extends StatefulWidget {
  const _FeedbackDetails({required this.outingId, required this.editMood});

  final String outingId;
  final bool editMood;

  @override
  State<_FeedbackDetails> createState() => _FeedbackDetailsState();
}

class _FeedbackDetailsState extends State<_FeedbackDetails> {
  late final OutingRepository _repo = getIt<OutingRepository>();
  late final TextEditingController _note;
  FeedbackMood? _mood;
  WakeFeeling? _wake;
  Hangover? _hangover;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final o = _repo.byId(widget.outingId);
    _mood = o?.feedbackMood;
    _wake = o?.wakeFeeling;
    _hangover = o?.hangover;
    _note = TextEditingController(text: o?.feedbackNote ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    if (widget.editMood && _mood != null) {
      await _repo.answerFeedback(widget.outingId, _mood!);
    }
    await _repo.setFeedbackDetails(
      widget.outingId,
      wake: _wake,
      hangover: _hangover,
      note: _note.text,
    );
    if (mounted) Navigator.pop(context, FeedbackDetailsResult.saved);
  }

  Widget _chips<T>(
    List<T> values,
    T? selected,
    String Function(T) label,
    ValueChanged<T?> onChanged,
  ) =>
      Wrap(
        spacing: AppSpace.sm,
        runSpacing: AppSpace.sm,
        children: [
          for (final v in values)
            ChoiceChip(
              label: Text(label(v)),
              selected: selected == v,
              showCheckmark: false,
              onSelected: (_) => onChanged(selected == v ? null : v),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl,
            AppSpace.lg + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.editMood ? tr.feedbackYourAccount : tr.feedbackTellMore,
                style: AppText.title),
            const SizedBox(height: AppSpace.xs),
            Text(tr.feedbackOptional, style: AppText.caption),
            if (widget.editMood) ...[
              const SizedBox(height: AppSpace.lg),
              Text(tr.feedbackHowItWent, style: AppText.overline),
              const SizedBox(height: AppSpace.sm),
              _chips<FeedbackMood>(FeedbackMood.values, _mood, (m) => m.label,
                  (v) => setState(() => _mood = v)),
            ],
            const SizedBox(height: AppSpace.lg),
            Text(tr.feedbackWake, style: AppText.overline),
            const SizedBox(height: AppSpace.sm),
            _chips<WakeFeeling>(WakeFeeling.values, _wake, (w) => w.label,
                (v) => setState(() => _wake = v)),
            const SizedBox(height: AppSpace.lg),
            Text(tr.feedbackHangover, style: AppText.overline),
            const SizedBox(height: AppSpace.sm),
            _chips<Hangover>(Hangover.values, _hangover, (h) => h.label,
                (v) => setState(() => _hangover = v)),
            const SizedBox(height: AppSpace.lg),
            TextField(
              controller: _note,
              maxLength: 300,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: tr.feedbackFreeNote,
                hintText: tr.feedbackFreeNoteHint,
              ),
            ),
            if (!widget.editMood)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      Navigator.pop(context, FeedbackDetailsResult.review),
                  icon: const Icon(Icons.history_edu_outlined, size: 18),
                  label: Text(tr.feedbackReviewForgotten),
                ),
              ),
            const SizedBox(height: AppSpace.sm),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(tr.commonSave),
            ),
            const SizedBox(height: AppSpace.xs),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.pop(context, FeedbackDetailsResult.skipped),
                child: Text(widget.editMood ? tr.commonCancel : tr.commonNotNow,
                    style: const TextStyle(color: AppColors.textMuted)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
