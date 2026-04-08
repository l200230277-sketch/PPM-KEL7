import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../models/drama.dart';
import '../widgets/drama_poster.dart';
import 'drama_detail_screen.dart';
import 'drama_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.isAdmin,
    required this.initialData,
    required this.onLogout,
  });

  final bool isAdmin;
  final List<Drama> initialData;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  late List<Drama> _dramas;
  late final Set<String> _popularIds;
  String _searchQuery = '';
  String _activeCategory = 'All';
  String _profileName = 'Minjung';
  String _profileEmail = 'minjung234@gmail.com';
  String _firstName = 'Minjung';
  String _lastName = 'Go';
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _dramas = [...widget.initialData];
    _popularIds = widget.initialData.take(2).map((d) => d.id).toSet();
  }

  Future<void> _openAddDrama() async {
    final result = await Navigator.push<DramaFormResult>(
      context,
      MaterialPageRoute(builder: (_) => const DramaFormScreen()),
    );
    if (result == null) return;

    setState(() {
      _dramas.insert(
        0,
        Drama(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: result.title,
          year: result.year,
          rating: result.rating,
          genres: result.genres,
          tags: result.tags,
          synopsis: result.synopsis,
          posterAsset: result.posterAsset,
          posterBytes: result.posterBytes,
          isFavorite: false,
          isInMyList: false,
          mainCast: result.mainCast,
        ),
      );
    });
  }

  Future<void> _openEditDrama(Drama drama) async {
    final result = await Navigator.push<DramaFormResult>(
      context,
      MaterialPageRoute(builder: (_) => DramaFormScreen(initialDrama: drama)),
    );
    if (result == null) return;

    setState(() {
      final index = _dramas.indexWhere((d) => d.id == drama.id);
      if (index == -1) return;
      _dramas[index] = _dramas[index].copyWith(
        title: result.title,
        year: result.year,
        rating: result.rating,
        genres: result.genres,
        tags: result.tags,
        synopsis: result.synopsis,
        posterAsset: result.posterAsset,
        posterBytes: result.posterBytes,
        mainCast: result.mainCast,
      );
    });
  }

  void _deleteDrama(Drama drama) {
    setState(() {
      _dramas.removeWhere((d) => d.id == drama.id);
    });
  }

  void _toggleFavorite(Drama drama) {
    setState(() {
      final index = _dramas.indexWhere((d) => d.id == drama.id);
      if (index == -1) return;
      final item = _dramas[index];
      _dramas[index] = item.copyWith(isFavorite: !item.isFavorite);
    });
  }

  void _toggleMyList(Drama drama) {
    setState(() {
      final index = _dramas.indexWhere((d) => d.id == drama.id);
      if (index == -1) return;
      final item = _dramas[index];
      _dramas[index] = item.copyWith(isInMyList: !item.isInMyList);
    });
  }

  Future<void> _openDetail(Drama drama) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DramaDetailScreen(
          drama: drama,
          isAdmin: widget.isAdmin,
          isFavorite: drama.isFavorite,
          isInMyList: drama.isInMyList,
          allDramas: _dramas,
          onOpenDrama: _openDetail,
          onEdit: widget.isAdmin ? () => _openEditDrama(drama) : null,
          onDelete: widget.isAdmin
              ? () {
                  _deleteDrama(drama);
                  Navigator.pop(context);
                }
              : null,
          onToggleFavorite: () => _toggleFavorite(drama),
          onToggleMyList: () => _toggleMyList(drama),
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141414),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Scaffold(
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
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildCurrentTab()),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: _BottomPillNavigation(
                        isAdmin: widget.isAdmin,
                        currentIndex: _tabIndex,
                        onTap: (index) => setState(() => _tabIndex = index),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_tabIndex) {
      case 0:
        return _CatalogTab(
          isAdmin: widget.isAdmin,
          profileName: widget.isAdmin ? 'admin' : _profileName,
          dramas: _dramas,
          popularIds: _popularIds,
          onOpenDetail: _openDetail,
          onEdit: _openEditDrama,
          activeCategory: _activeCategory,
          searchQuery: _searchQuery,
          onProfileTap: () => setState(() => _tabIndex = 3),
          onCategorySelected: (value) => setState(() => _activeCategory = value),
          onSearchChanged: (value) => setState(() => _searchQuery = value),
        );
      case 1:
        return _SimpleListTab(
          title: 'My Favorit',
          dramas: _dramas.where((d) => d.isFavorite).toList(),
          onOpenDetail: _openDetail,
          onBack: () => setState(() => _tabIndex = 0),
          onToggleFavorite: _toggleFavorite,
        );
      case 2:
        return _SimpleListTab(
          title: 'My List',
          dramas: _dramas.where((d) => d.isInMyList).toList(),
          onOpenDetail: _openDetail,
          onBack: () => setState(() => _tabIndex = 0),
          onToggleMyList: _toggleMyList,
        );
      default:
        return _ProfileTab(
          isAdmin: widget.isAdmin,
          onLogout: widget.onLogout,
          profileName: widget.isAdmin ? 'Admin' : _profileName,
          email: widget.isAdmin ? 'admin1@gmail.com' : _profileEmail,
          firstName: widget.isAdmin ? 'Admin' : _firstName,
          lastName: widget.isAdmin ? '' : _lastName,
          initialImageBytes: _profileImageBytes,
          onSave: (firstName, lastName, email) {
            setState(() {
              _firstName = firstName;
              _lastName = lastName;
              _profileEmail = email;
              _profileName =
                  [firstName, lastName].where((e) => e.trim().isNotEmpty).join(' ');
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile saved successfully.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onImagePicked: (bytes) {
            setState(() => _profileImageBytes = bytes);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile photo updated.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onAddKdrama: widget.isAdmin ? _openAddDrama : null,
        );
    }
  }
}


class _CatalogTab extends StatelessWidget {
  const _CatalogTab({
    required this.isAdmin,
    required this.profileName,
    required this.dramas,
    required this.popularIds,
    required this.onOpenDetail,
    required this.onEdit,
    required this.activeCategory,
    required this.searchQuery,
    required this.onProfileTap,
    required this.onCategorySelected,
    required this.onSearchChanged,
  });

  final bool isAdmin;
  final String profileName;
  final List<Drama> dramas;
  final Set<String> popularIds;
  final ValueChanged<Drama> onOpenDetail;
  final ValueChanged<Drama> onEdit;
  final String activeCategory;
  final String searchQuery;
  final VoidCallback onProfileTap;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final filtered = dramas.where((drama) {
      final matchesQuery =
          drama.title.toLowerCase().contains(searchQuery.toLowerCase());
      if (!matchesQuery) return false;
      if (activeCategory == 'All') return true;
      return drama.genres.any(
        (g) => g.toLowerCase() == activeCategory.toLowerCase(),
      );
    }).toList();

    final popular = filtered.where((d) => popularIds.contains(d.id)).take(2).toList();
    final recent = filtered.where((d) => !popularIds.contains(d.id)).take(2).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 140),
      children: [
        Row(
          children: [
            Text(
              'hello, ',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            Text(
              '${profileName.toLowerCase()}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white.withValues(alpha: 0.7),
                child: const Icon(Icons.person, color: Color(0xFF0F4A5D), size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _SearchField(onChanged: onSearchChanged),
        const SizedBox(height: 16),

        const Text(
          'Select Categories',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['All', 'Thriller', 'Action', 'Horror'].map((category) {
            return _CategoryChip(
              label: category,
              active: category == activeCategory,
              onTap: () => onCategorySelected(category),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        const Text(
          'Popular drama',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: popular.isEmpty
              ? const _EmptyCard(text: 'No popular drama.')
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popular.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final drama = popular[index];
                    return _PopularDramaCard(
                      drama: drama,
                      onTap: () => onOpenDetail(drama),
                      onEdit: isAdmin ? () => onEdit(drama) : null,
                    );
                  },
                ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Recently added',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          const _EmptyCard(text: 'No data available.')
        else
          ...recent.map(
            (drama) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _RecentDramaBanner(
                drama: drama,
                onTap: () => onOpenDetail(drama),
                onEdit: isAdmin ? () => onEdit(drama) : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _PopularDramaCard extends StatelessWidget {
  const _PopularDramaCard({
    required this.drama,
    required this.onTap,
    this.onEdit,
  });

  final Drama drama;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final badgeColor = _genreBadgeColor();
    final badgeTextColor = _genreBadgeTextColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFCADADD),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DramaPoster(
                        assetPath: drama.posterAsset,
                        imageBytes: drama.posterBytes,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          drama.primaryGenre,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      drama.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2E3A40),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Color(0xFF2E3A40),
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

class _RecentDramaBanner extends StatelessWidget {
  const _RecentDramaBanner({
    required this.drama,
    required this.onTap,
    this.onEdit,
  });

  final Drama drama;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF1C4F5A),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DramaPoster(
              assetPath: drama.posterAsset,
              imageBytes: drama.posterBytes,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            drama.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${drama.year} · ${drama.primaryGenre} · ★ ${drama.rating}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onEdit != null)
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_outlined,
                              size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleListTab extends StatelessWidget {
  const _SimpleListTab({
    required this.title,
    required this.dramas,
    required this.onOpenDetail,
    required this.onBack,
    this.onToggleFavorite,
    this.onToggleMyList,
  });

  final String title;
  final List<Drama> dramas;
  final ValueChanged<Drama> onOpenDetail;
  final VoidCallback onBack;
  final ValueChanged<Drama>? onToggleFavorite;
  final ValueChanged<Drama>? onToggleMyList;

  @override
  Widget build(BuildContext context) {
    const panelColor = Color(0xFFABC6C9);
    return LayoutBuilder(
      builder: (context, constraints) {
        const panelPadding = 14.0;
        const rowHeight = 86.0;
        const separator = 12.0;
        const emptyPanelHeight = 110.0;
        final count = dramas.length;
        final contentHeight = count == 0
            ? emptyPanelHeight
            : (panelPadding * 2) +
                (count * rowHeight) +
                ((count - 1) * separator);
        final maxPanelHeight = constraints.maxHeight - 70; 
        final panelHeight = contentHeight.clamp(0, maxPanelHeight);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 140),
          child: Column(
            children: [
              Row(
                children: [
                  _MiniCircleIcon(icon: Icons.arrow_back, onTap: onBack),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: panelHeight.toDouble(),
                child: Container(
                  padding: const EdgeInsets.all(panelPadding),
                  decoration: BoxDecoration(
                    color: panelColor.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: dramas.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada item.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.separated(
                          physics: count <= 3
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          itemCount: dramas.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: separator),
                          itemBuilder: (context, index) {
                            final drama = dramas[index];
                            final trailing = onToggleFavorite != null
                                ? IconButton(
                                    onPressed: () => onToggleFavorite!(drama),
                                    icon: Icon(
                                      drama.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.redAccent,
                                    ),
                                  )
                                : onToggleMyList != null
                                    ? IconButton(
                                        onPressed: () =>
                                            onToggleMyList!(drama),
                                        icon: Icon(
                                          drama.isInMyList
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: drama.isInMyList
                                              ? Colors.redAccent
                                              : const Color(0xFF2C3F46),
                                        ),
                                      )
                                    : null;

                            return SizedBox(
                              height: rowHeight,
                              child: _DramaRow(
                                drama: drama,
                                onTap: () => onOpenDetail(drama),
                                trailing: trailing,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniCircleIcon extends StatelessWidget {
  const _MiniCircleIcon({required this.icon, required this.onTap});

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

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({
    required this.isAdmin,
    required this.onLogout,
    required this.profileName,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.initialImageBytes,
    required this.onSave,
    required this.onImagePicked,
    this.onAddKdrama,
  });

  final bool isAdmin;
  final VoidCallback onLogout;
  final String profileName;
  final String email;
  final String firstName;
  final String lastName;
  final Uint8List? initialImageBytes;
  final void Function(String firstName, String lastName, String email) onSave;
  final ValueChanged<Uint8List> onImagePicked;
  final Future<void> Function()? onAddKdrama;

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _emailCtrl;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController(text: widget.firstName);
    _lastCtrl = TextEditingController(text: widget.lastName);
    _emailCtrl = TextEditingController(text: widget.email);
    _imageBytes = widget.initialImageBytes;
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageBytes = bytes);
    widget.onImagePicked(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 140),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => widget.onSave(
                _firstCtrl.text, _lastCtrl.text, _emailCtrl.text),
            child: const Text(
              'Save',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.white54,
              backgroundImage:
                  _imageBytes == null ? null : MemoryImage(_imageBytes!),
              child: _imageBytes == null
                  ? const Icon(Icons.person, size: 62, color: Colors.white)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            widget.profileName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            _emailCtrl.text,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 22),
        if (widget.isAdmin)
          _ProfileAction(
            title: 'Add Kdrama',
            subtitle: 'Upload poster, title, genre, and more',
            onTap: widget.onAddKdrama,
          ),
        const SizedBox(height: 12),
        _ProfileTextField(label: 'Email address', controller: _emailCtrl),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ProfileTextField(
                  label: 'First Name', controller: _firstCtrl),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProfileTextField(
                  label: 'Last Name', controller: _lastCtrl),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: widget.onLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B6588),
            foregroundColor: Colors.white,
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}


class _DramaRow extends StatelessWidget {
  const _DramaRow({
    required this.drama,
    required this.onTap,
    this.trailing,
  });

  final Drama drama;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFBFDADD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: DramaPoster(
                  assetPath: drama.posterAsset,
                  imageBytes: drama.posterBytes,
                  width: 90,
                  height: 66,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drama.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${drama.year} – ${drama.primaryGenre}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.black87),
                        const SizedBox(width: 6),
                        Text(
                          drama.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'search for a KDrama',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const Icon(Icons.search, color: Colors.white70),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    this.active = false,
    this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF0B6588)
              : Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.85)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF608B95),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD2E5E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text,
          style: const TextStyle(color: Color(0xFF213B47))),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField(
      {required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}


class _BottomPillNavigation extends StatelessWidget {
  const _BottomPillNavigation({
    required this.isAdmin,
    required this.currentIndex,
    required this.onTap,
  });

  final bool isAdmin;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const selected = Color(0xFF1B3844);
    const unselected = Color(0xFF304E59);

    if (isAdmin) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF5A888F).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => onTap(0),
                icon: Icon(
                  Icons.home_outlined,
                  color: currentIndex == 0 ? selected : unselected,
                ),
              ),
              const SizedBox(width: 56),
              IconButton(
                onPressed: () => onTap(3),
                icon: Icon(
                  Icons.settings_outlined,
                  color: currentIndex == 3 ? selected : unselected,
                ),
              ),
            ],
          ),
        ),
      );
    }

    const items = [
      Icons.home_outlined,
      Icons.favorite_border,
      Icons.bookmark_border,
      Icons.settings_outlined,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF5A888F).withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final isSelected = index == currentIndex;
            return IconButton(
              onPressed: () => onTap(index),
              icon: Icon(
                items[index],
                color: isSelected ? selected : unselected,
              ),
            );
          }),
        ),
      ),
    );
  }
}

Color _genreBadgeColor() => const Color(0xFFCADADD);

Color _genreBadgeTextColor() => const Color(0xFF2E3A40);