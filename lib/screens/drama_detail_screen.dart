import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:share_plus/share_plus.dart';

import '../models/drama.dart';
import '../widgets/drama_poster.dart';

class DramaDetailScreen extends StatefulWidget {
  const DramaDetailScreen({
    super.key,
    required this.drama,
    required this.isAdmin,
    required this.isFavorite,
    required this.isInMyList,
    this.allDramas,
    this.onOpenDrama,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
    this.onToggleMyList,
  });

  final Drama drama;
  final bool isAdmin;
  final bool isFavorite;
  final bool isInMyList;
  final List<Drama>? allDramas;
  final ValueChanged<Drama>? onOpenDrama;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onToggleMyList;

  @override
  State<DramaDetailScreen> createState() => _DramaDetailScreenState();
}

class _DramaDetailScreenState extends State<DramaDetailScreen> {
  late bool _isFavorite;
  late bool _isInMyList;
  late final ScrollController _recoController;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _isInMyList = widget.isInMyList;
    _recoController = ScrollController();
  }

  @override
  void dispose() {
    _recoController.dispose();
    super.dispose();
  }

  Future<void> _shareDrama() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Check this K-Drama: ${widget.drama.title} (${widget.drama.year}) - rating ${widget.drama.rating}/10',
      ),
    );
  }

  void _onToggleFavorite() {
    widget.onToggleFavorite?.call();
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorite.' : 'Removed from favorite.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onToggleMyList() {
    widget.onToggleMyList?.call();
    setState(() => _isInMyList = !_isInMyList);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isInMyList ? 'Added to My List.' : 'Removed from My List.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static const _cardMint = Color(0xFFCADADD);
  static const _tagFill = Color(0xFFCADADD);
  static const _tagText = Color(0xFF2E3A40);
  static const _recoCard = Color(0xFF2B6675);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3B4C),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DC8CE), Color(0xFF0A3B4C)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 620,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DramaPoster(
                          assetPath: widget.drama.posterAsset,
                          imageBytes: widget.drama.posterBytes,
                          fit: BoxFit.cover,
                          borderRadius: 0,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.12),
                                Colors.black.withValues(alpha: 0.72),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            _RoundIconButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            _RoundIconButton(
                              icon: Icons.share_outlined,
                              onTap: _shareDrama,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 18,
                        child: _DetailInfoCard(
                          year: widget.drama.year,
                          rating: widget.drama.rating,
                          genres: widget.drama.genres,
                          tags: widget.drama.tags,
                          title: widget.drama.title,
                          synopsis: widget.drama.synopsis,
                          isAdmin: widget.isAdmin,
                          isFavorite: _isFavorite,
                          isInMyList: _isInMyList,
                          onEdit: widget.onEdit,
                          onDelete: widget.onDelete,
                          onToggleFavorite: _onToggleFavorite,
                          onToggleMyList: _onToggleMyList,
                          tagFill: _tagFill,
                          tagText: _tagText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Main Cast',
                    style: TextStyle(
                      color: Colors.brown.shade800,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _cardMint,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: widget.drama.mainCast.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No cast info yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF4B5961)),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < widget.drama.mainCast.length; i++) ...[
                              if (i > 0) const SizedBox(width: 12),
                              Expanded(
                                child: _CastTile(member: widget.drama.mainCast[i]),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'You may also like',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 240,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: ListView(
                      controller: _recoController,
                      primary: false,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 16, right: 4),
                      children: [
                        SizedBox(
                          width: 200,
                          child: _RecommendCard(
                            imagePath: 'assets/images/rekomen1.jpg',
                            title: 'Love Alarm',
                            cardColor: _recoCard,
                            onTap: () => _openReco('Love Alarm'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 200,
                          child: _RecommendCard(
                            imagePath: 'assets/images/rekomen2.jpg',
                            title: 'My Name',
                            cardColor: _recoCard,
                            onTap: () => _openReco('My Name'),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openReco(String title) {
    final list = widget.allDramas;
    final found = list?.firstWhere(
      (d) => d.title.toLowerCase() == title.toLowerCase(),
      orElse: () => const Drama(
        id: '',
        title: '',
        year: 0,
        rating: 0,
        genres: [],
        tags: [],
        synopsis: '',
        posterAsset: '',
        isFavorite: false,
        isInMyList: false,
      ),
    );
    if (found != null && found.id.isNotEmpty) {
      widget.onOpenDrama?.call(found);
      return;
    }

    // Fallback: same flow as catalog (admin/public) so callbacks match.
    final reco = _recoDrama(title);
    if (reco == null) return;
    widget.onOpenDrama?.call(reco);
  }

  Drama? _recoDrama(String title) {
    switch (title.toLowerCase()) {
      case 'love alarm':
        return const Drama(
          id: 'reco_love_alarm',
          title: 'Love Alarm',
          year: 2019,
          rating: 8.4,
          genres: ['Romance'],
          tags: ['Life'],
          synopsis:
              'A romance drama where an app reveals who likes you within 10 meters.',
          posterAsset: 'assets/images/rekomen1.jpg',
          isFavorite: false,
          isInMyList: false,
        );
      case 'my name':
        return const Drama(
          id: 'reco_my_name',
          title: 'My Name',
          year: 2021,
          rating: 8.6,
          genres: ['Thriller'],
          tags: ['Action'],
          synopsis:
              'A revenge story as a woman joins a gang and infiltrates the police.',
          posterAsset: 'assets/images/rekomen2.jpg',
          isFavorite: false,
          isInMyList: false,
        );
      default:
        return null;
    }
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 0.85,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: member.photoBytes != null
                ? Image.memory(member.photoBytes!, fit: BoxFit.cover)
                : member.photoAssetPath.isNotEmpty
                    ? Image.asset(member.photoAssetPath, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF8EB2B7),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person, color: Colors.white54),
                      ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          member.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF4B5961),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RecommendCard extends StatelessWidget {
  const _RecommendCard({
    required this.imagePath,
    required this.title,
    required this.cardColor,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final Color cardColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

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
        child: Icon(icon, color: const Color(0xFF133343)),
      ),
    );
  }
}

class _DetailInfoCard extends StatelessWidget {
  const _DetailInfoCard({
    required this.year,
    required this.rating,
    required this.genres,
    required this.tags,
    required this.title,
    required this.synopsis,
    required this.isAdmin,
    required this.isFavorite,
    required this.isInMyList,
    this.onEdit,
    this.onDelete,
    required this.onToggleFavorite,
    required this.onToggleMyList,
    required this.tagFill,
    required this.tagText,
  });

  final int year;
  final double rating;
  final List<String> genres;
  final List<String> tags;
  final String title;
  final String synopsis;
  final bool isAdmin;
  final bool isFavorite;
  final bool isInMyList;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleMyList;
  final Color tagFill;
  final Color tagText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xB82D5562),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TagPill(label: year.toString(), fill: tagFill, textColor: tagText),
              _TagPill(
                label: '${rating.toStringAsFixed(1)}/10',
                fill: tagFill,
                textColor: tagText,
              ),
              for (final g in genres)
                _TagPill(label: g, fill: tagFill, textColor: tagText),
              for (final t in tags)
                _TagPill(label: t, fill: tagFill, textColor: tagText),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            synopsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (!isAdmin)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onToggleMyList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F8D93),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        isInMyList ? 'Added to my list' : 'Add to my list',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: onToggleFavorite,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FA5AA),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1D697B), width: 2),
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : const Color(0xFF244D59),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF638F98),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Edit KDrama'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF153241),
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.label,
    required this.fill,
    required this.textColor,
  });

  final String label;
  final Color fill;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
