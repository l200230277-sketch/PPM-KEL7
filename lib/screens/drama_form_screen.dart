import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/drama.dart';
import 'main_cast_edit_screen.dart';

class DramaFormResult {
  const DramaFormResult({
    required this.title,
    required this.year,
    required this.rating,
    required this.genres,
    required this.tags,
    required this.synopsis,
    required this.posterAsset,
    this.posterBytes,
    this.mainCast = const [],
  });

  final String title;
  final int year;
  final double rating;
  final List<String> genres;
  final List<String> tags;
  final String synopsis;
  final String posterAsset;
  final Uint8List? posterBytes;
  final List<CastMember> mainCast;
}

class DramaFormScreen extends StatefulWidget {
  const DramaFormScreen({super.key, this.initialDrama});

  final Drama? initialDrama;

  bool get isEditMode => initialDrama != null;

  @override
  State<DramaFormScreen> createState() => _DramaFormScreenState();
}

class _DramaFormScreenState extends State<DramaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _genreInputCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();
  final _synopsisCtrl = TextEditingController();

  Uint8List? _posterBytes;
  String _posterAssetPath = '';
  final List<String> _genres = [];
  final List<String> _tags = [];
  List<CastMember> _mainCast = [];

  static const _cardColor = Color(0xFF5F8D8D);
  static const _fieldFill = Color(0xFF4A7575);

  @override
  void initState() {
    super.initState();
    final drama = widget.initialDrama;
    if (drama != null) {
      _titleCtrl.text = drama.title;
      _yearCtrl.text = drama.year.toString();
      _ratingCtrl.text = drama.rating.toString();
      _synopsisCtrl.text = drama.synopsis;
      _posterAssetPath = drama.posterAsset;
      _posterBytes = drama.posterBytes;
      _genres.addAll(drama.genres);
      _tags.addAll(drama.tags);
      _mainCast = List<CastMember>.from(drama.mainCast);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _ratingCtrl.dispose();
    _genreInputCtrl.dispose();
    _tagInputCtrl.dispose();
    _synopsisCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPoster() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _posterBytes = bytes;
      _posterAssetPath = '';
    });
  }

  Future<void> _openMainCast() async {
    final result = await Navigator.push<List<CastMember>>(
      context,
      MaterialPageRoute(
        builder: (_) => MainCastEditScreen(initialCast: _mainCast),
      ),
    );
    if (result != null) {
      setState(() => _mainCast = result);
    }
  }

  void _addGenre() {
    final v = _genreInputCtrl.text.trim();
    if (v.isEmpty) return;
    setState(() {
      if (!_genres.any((g) => g.toLowerCase() == v.toLowerCase())) {
        _genres.add(v);
      }
      _genreInputCtrl.clear();
    });
  }

  void _addTag() {
    final v = _tagInputCtrl.text.trim();
    if (v.isEmpty) return;
    setState(() {
      if (!_tags.any((t) => t.toLowerCase() == v.toLowerCase())) {
        _tags.add(v);
      }
      _tagInputCtrl.clear();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_genres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one genre.')),
      );
      return;
    }
    final path = _posterAssetPath.trim();
    if (_posterBytes == null && path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload a poster first.')),
      );
      return;
    }

    final result = DramaFormResult(
      title: _titleCtrl.text.trim(),
      year: int.parse(_yearCtrl.text.trim()),
      rating: double.parse(_ratingCtrl.text.trim()),
      genres: List<String>.from(_genres),
      tags: List<String>.from(_tags),
      synopsis: _synopsisCtrl.text.trim(),
      posterAsset: path,
      posterBytes: _posterBytes,
      mainCast: List<CastMember>.from(_mainCast),
    );
    Navigator.pop(context, result);
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditMode ? 'Edit KDrama' : 'Add KDrama';

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
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardColor,
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
                          _posterUpload(),
                          const SizedBox(height: 16),
                          _labeledField(
                            label: 'Title',
                            child: _sunkenField(
                              controller: _titleCtrl,
                              validator: _required,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _labeledField(
                                  label: 'Release year',
                                  child: _sunkenField(
                                    controller: _yearCtrl,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (_required(v) != null) return _required(v);
                                      return int.tryParse(v!.trim()) == null
                                          ? 'Angka'
                                          : null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _labeledField(
                                  label: 'Rating',
                                  child: _sunkenField(
                                    controller: _ratingCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    validator: (v) {
                                      if (_required(v) != null) return _required(v);
                                      final p = double.tryParse(v!.trim());
                                      if (p == null) return 'Invalid';
                                      if (p < 0 || p > 10) return '0–10';
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _labeledField(
                            label: 'Genre',
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _sunkenField(
                                    controller: _genreInputCtrl,
                                    hint: 'Add genre',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _addGenre,
                                  style: IconButton.styleFrom(
                                    backgroundColor: _fieldFill,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.add, size: 22),
                                ),
                              ],
                            ),
                          ),
                          if (_genres.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _genres
                                  .map(
                                    (g) => Chip(
                                      label: Text(g),
                                      onDeleted: () =>
                                          setState(() => _genres.remove(g)),
                                      deleteIconColor: Colors.white70,
                                      backgroundColor: _fieldFill,
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _labeledField(
                            label: 'Tags',
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _sunkenField(
                                    controller: _tagInputCtrl,
                                    hint: 'Add tag',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _addTag,
                                  style: IconButton.styleFrom(
                                    backgroundColor: _fieldFill,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.add, size: 22),
                                ),
                              ],
                            ),
                          ),
                          if (_tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _tags
                                  .map(
                                    (t) => Chip(
                                      label: Text(t),
                                      onDeleted: () =>
                                          setState(() => _tags.remove(t)),
                                      deleteIconColor: Colors.white70,
                                      backgroundColor: _fieldFill,
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _labeledField(
                            label: 'Synopsis',
                            child: _sunkenField(
                              controller: _synopsisCtrl,
                              minLines: 3,
                              maxLines: 5,
                              pill: false,
                              validator: _required,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              onPressed: _openMainCast,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                                backgroundColor: _fieldFill,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Main Cast (${_mainCast.length})',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _posterUpload() {
    return Material(
      color: const Color(0xFFD8E4E5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _pickPoster,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _posterBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_posterBytes!, fit: BoxFit.cover),
                  )
                : _posterAssetPath.trim().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _posterAssetPath.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _posterPlaceholder(),
                        ),
                      )
                    : _posterPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image_outlined, size: 48, color: Color(0xFF5A6A6D)),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(fontSize: 13, color: Color(0xFF4A5558)),
            children: [
              TextSpan(
                text: 'Click here',
                style: TextStyle(
                  color: Color(0xFFE85D75),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: ' to upload a K-drama poster',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _sunkenField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
    String? hint,
    void Function(String)? onChanged,
    bool pill = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(pill ? 999 : 18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
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
