import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/drama.dart';

/// Admin: add one or more cast members (photo + name). Returns updated list on pop.
class MainCastEditScreen extends StatefulWidget {
  const MainCastEditScreen({super.key, required this.initialCast});

  final List<CastMember> initialCast;

  @override
  State<MainCastEditScreen> createState() => _MainCastEditScreenState();
}

class _MainCastEditScreenState extends State<MainCastEditScreen> {
  late List<_CastDraft> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.initialCast
        .map((c) => _CastDraft(
              name: c.name,
              assetPath: c.photoAssetPath,
              bytes: c.photoBytes,
            ))
        .toList();
    if (_rows.isEmpty) {
      _rows.add(_CastDraft());
    }
  }

  Future<void> _pickPhoto(int index) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _rows[index].bytes = bytes;
      _rows[index].assetPath = '';
    });
  }

  void _addRow() {
    setState(() => _rows.add(_CastDraft()));
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].nameCtrl.dispose();
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add(_CastDraft());
    });
  }

  void _save() {
    final out = <CastMember>[];
    for (final r in _rows) {
      final name = r.nameCtrl.text.trim();
      if (name.isEmpty &&
          r.assetPath.isEmpty &&
          (r.bytes == null || r.bytes!.isEmpty)) {
        continue;
      }
      if (name.isEmpty) continue;
      out.add(CastMember(
        name: name,
        photoAssetPath: r.assetPath,
        photoBytes: r.bytes,
      ));
    }
    Navigator.pop(context, out);
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.nameCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF5F8D8D);
    const fieldFill = Color(0xFF4A7575);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DC8CE), Color(0xFF0A1E24)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Row(
                  children: [
                    _CircleIcon(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Edit Main Cast',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < _rows.length; i++) ...[
                          if (i > 0) const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildUploadBox(i, fieldFill)),
                              IconButton(
                                onPressed: () => _removeRow(i),
                                icon: const Icon(Icons.close, color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: fieldFill,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _rows[i].nameCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _addRow,
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          label: const Text(
                            'Add another cast',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A1A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'SAVE',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBox(int index, Color fieldFill) {
    final r = _rows[index];
    return Material(
      color: const Color(0xFFD8E4E5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _pickPhoto(index),
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 0.85,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (r.bytes != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(r.bytes!, fit: BoxFit.cover),
                    ),
                  )
                else if (r.assetPath.isNotEmpty)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(r.assetPath, fit: BoxFit.cover),
                    ),
                  )
                else ...[
                  const Icon(Icons.image_outlined, size: 48, color: Color(0xFF5A6A6D)),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12, color: Color(0xFF4A5558)),
                      children: [
                        TextSpan(
                          text: 'Click here',
                          style: TextStyle(
                            color: Color(0xFFE85D75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' to upload a main cast photo',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CastDraft {
  _CastDraft({
    String name = '',
    this.assetPath = '',
    this.bytes,
  }) : nameCtrl = TextEditingController(text: name);

  final TextEditingController nameCtrl;
  String assetPath;
  Uint8List? bytes;
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xA0A5BEC4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF133343), size: 22),
      ),
    );
  }
}
