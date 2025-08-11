import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HostDocumentService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  double _progress = 0.0;
  bool _isUploading = false;
  String? _error;
  Map<String, bool> _uploadedByType = {};

  double get progress => _progress;
  bool get isUploading => _isUploading;
  String? get error => _error;
  Map<String, bool> get uploadedByType => _uploadedByType;

  void _reset() {
    _progress = 0.0;
    _isUploading = false;
    _error = null;
  }

  Future<void> loadExistingUploads() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final rows = await _client
        .from('host_documents')
        .select('type')
        .eq('user_id', user.id);
    final map = <String, bool>{};
    for (final r in rows as List) {
      final t = r['type'] as String?;
      if (t != null) map[t] = true;
    }
    _uploadedByType = map;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> uploadHostDocument({
    required File file,
    required String docType, // id_front | id_back | license | ownership | selfie_optional
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _error = 'Please sign in';
      notifyListeners();
      return null;
    }

    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final ext = file.path.split('.').last;
      final objectPath = '${user.id}/'+
          '${docType}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      // Upload to storage (bucket host-docs)
      await _client.storage
          .from('host-docs')
          .upload(objectPath, file);

      // Insert DB row
      final row = await _client
          .from('host_documents')
          .insert({
            'user_id': user.id,
            'type': docType,
            'storage_path': objectPath,
          })
          .select()
          .single();

      _progress = 1.0;
      _isUploading = false;
      _uploadedByType[docType] = true;
      notifyListeners();
      return row;
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }
}


