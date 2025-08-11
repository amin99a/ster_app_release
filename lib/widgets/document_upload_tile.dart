import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/host_document_service.dart';

class DocumentUploadTile extends StatefulWidget {
  final String title;
  final String docType; // id_front | id_back | license | ownership | selfie_optional
  final void Function(bool uploaded) onStateChanged;
  final bool initialUploaded;

  const DocumentUploadTile({
    super.key,
    required this.title,
    required this.docType,
    required this.onStateChanged,
    this.initialUploaded = false,
  });

  @override
  State<DocumentUploadTile> createState() => _DocumentUploadTileState();
}

class _DocumentUploadTileState extends State<DocumentUploadTile> {
  bool _uploaded = false;
  double _progress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _uploaded = widget.initialUploaded;
  }

  @override
  void didUpdateWidget(covariant DocumentUploadTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialUploaded != widget.initialUploaded) {
      _uploaded = widget.initialUploaded;
    }
  }

  Future<void> _pickAndUpload() async {
    setState(() {
      _error = null;
    });
    final result = await FilePicker.platform.pickFiles(withData: false, allowMultiple: false);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;

    final file = File(path);
    final svc = context.read<HostDocumentService>();
    svc.addListener(_syncProgress);
    final row = await svc.uploadHostDocument(file: file, docType: widget.docType);
    svc.removeListener(_syncProgress);
    if (!mounted) return;
    if (row != null) {
      setState(() {
        _uploaded = true;
        _progress = 1.0;
      });
      widget.onStateChanged(true);
    } else {
      setState(() {
        _error = svc.error;
        _uploaded = false;
      });
      widget.onStateChanged(false);
    }
  }

  void _syncProgress() {
    final svc = context.read<HostDocumentService>();
    setState(() {
      _progress = svc.progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Text(widget.title),
      subtitle: _error != null
          ? Text(_error!, style: const TextStyle(color: Colors.red))
          : _uploaded
              ? const Text('Uploaded')
              : (_progress > 0 && _progress < 1.0)
                  ? LinearProgressIndicator(value: _progress)
                  : const Text('Not uploaded'),
      trailing: ElevatedButton(
        onPressed: _pickAndUpload,
        child: Text(_uploaded ? 'Replace' : 'Upload'),
      ),
    );
  }
}


