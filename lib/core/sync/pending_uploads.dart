import 'package:supabase_flutter/supabase_flutter.dart';

/// Work that goes beyond rows (e.g. private photo uploads) and runs after the
/// rows of a sync pass. It must never throw into the sync: a failure only
/// means "try again on the next pass", and the structured data is never held
/// back by it.
abstract class PendingUploads {
  Future<void> run(SupabaseClient client, String ownerId);
}
