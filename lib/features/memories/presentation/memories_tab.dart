import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/ai/ai_provider.dart';
import '../../../core/theme/app_pallete.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../trips/presentation/trip_planner_controller.dart';
import '../data/memory_repository.dart';
import '../data/scrapbook_ai_service.dart';
import '../domain/memory_model.dart';

final scrapbookAiServiceProvider = Provider<ScrapbookAiService>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  return ScrapbookAiService(aiService: aiService, memoryRepository: memoryRepo);
});

class MemoriesTab extends ConsumerStatefulWidget {
  final String tripId;

  const MemoriesTab({super.key, required this.tripId});

  @override
  ConsumerState<MemoriesTab> createState() => _MemoriesTabState();
}

class _MemoriesTabState extends ConsumerState<MemoriesTab> {
  String _selectedCategory = 'all';
  final _picker = ImagePicker();
  bool _isGeneratingScrapbook = false;

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'All Moments', 'icon': '✨'},
    {'id': 'beaches', 'label': 'Beaches', 'icon': '🏖️'},
    {'id': 'food', 'label': 'Food & Drinks', 'icon': '🍽️'},
    {'id': 'sunset', 'label': 'Sunsets', 'icon': '🌅'},
    {'id': 'activities', 'label': 'Adventures', 'icon': '🎒'},
    {'id': 'group', 'label': 'Our People', 'icon': '👥'},
  ];

  Future<void> _openAddMemorySheet(BuildContext context) async {
    final captionController = TextEditingController();
    final locationController = TextEditingController();
    String category = 'general';
    XFile? pickedFile;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add Group Memory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                            if (file != null) setSheetState(() => pickedFile = file);
                          },
                          icon: const Icon(Icons.photo_library),
                          label: Text(pickedFile != null ? 'Photo Selected ✓' : 'Pick Photo'),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () async {
                            final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                            if (file != null) setSheetState(() => pickedFile = file);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: captionController,
                      decoration: const InputDecoration(
                        labelText: 'Caption / Story',
                        hintText: 'Sunset drinks at the shack...',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        hintText: 'e.g. Beach or City center',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'general', child: Text('General')),
                        DropdownMenuItem(value: 'beaches', child: Text('🏖️ Beaches')),
                        DropdownMenuItem(value: 'food', child: Text('🍽️ Food & Drinks')),
                        DropdownMenuItem(value: 'sunset', child: Text('🌅 Sunsets')),
                        DropdownMenuItem(value: 'activities', child: Text('🎒 Adventures')),
                        DropdownMenuItem(value: 'group', child: Text('👥 Our People')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final caption = captionController.text.trim();
                          if (caption.isEmpty && pickedFile == null) return;

                          final user = await ref.read(authRepositoryProvider).getCurrentUser();
                          if (user == null) return;

                          final memory = MemoryItem(
                            id: const Uuid().v4(),
                            tripId: widget.tripId,
                            mediaUrl: pickedFile != null
                                ? pickedFile!.path
                                : 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
                            caption: caption.isNotEmpty ? caption : 'Group Memory',
                            category: category,
                            locationName: locationController.text.trim().isNotEmpty
                                ? locationController.text.trim()
                                : null,
                            uploadedBy: user.uid,
                            uploaderName: user.displayName.isNotEmpty ? user.displayName : 'Friend',
                            uploadedAt: DateTime.now(),
                          );

                          await ref.read(memoryRepositoryProvider).addMemory(memory);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Post Memory', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _generateScrapbook() async {
    setState(() => _isGeneratingScrapbook = true);
    showSnackBar(context, '✨ CoCircle Magic is generating your Trip Recap & Scrapbook...');

    try {
      final trip = await ref.read(tripDetailsProvider(widget.tripId).future);
      final members = await ref.read(circleMembersProvider(trip.circleId).future);
      final memberNames = members.map((m) => m.displayName.isNotEmpty ? m.displayName : 'Member').toList();

      final memories = await ref.read(tripMemoriesProvider(widget.tripId).future);
      final captions = memories.map((m) => m.caption).toList();

      final itinerary = await ref.read(tripItineraryProvider(widget.tripId).future);
      final itineraryTitles = itinerary.map((i) => i.title).toList();

      final scrapbookService = ref.read(scrapbookAiServiceProvider);
      final scrapbook = await scrapbookService.generateTripScrapbook(
        tripId: widget.tripId,
        tripName: trip.name,
        location: trip.location,
        startDate: trip.startDate,
        endDate: trip.endDate,
        memberNames: memberNames,
        itineraryTitles: itineraryTitles,
        memoryCaptions: captions,
        totalExpenses: trip.totalExpenses,
      );

      if (mounted) {
        setState(() => _isGeneratingScrapbook = false);
        _showScrapbookDialog(scrapbook);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingScrapbook = false);
        showSnackBar(context, 'Scrapbook generation failed: $e');
      }
    }
  }

  void _showScrapbookDialog(TripScrapbook scrapbook) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.9,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Cover Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'OUR DIGITAL SCRAPBOOK ✨',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              scrapbook.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scrapbook.subtitle,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Narrative Story
                      const Text(
                        'Trip Story',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scrapbook.story,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Highlights
                      if (scrapbook.highlights.isNotEmpty) ...[
                        const Text(
                          'Unforgettable Highlights',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...scrapbook.highlights.map((h) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('✨ ', style: TextStyle(fontSize: 14)),
                                Expanded(child: Text(h, style: const TextStyle(fontSize: 14))),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],

                      // Superlatives
                      if (scrapbook.superlatives.isNotEmpty) ...[
                        const Text(
                          'Trip Superlatives & Awards',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: scrapbook.superlatives.entries.map((entry) {
                            return Chip(
                              avatar: const Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                              label: Text('${entry.key}: ${entry.value}'),
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Share Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final shareText = '''
📖 ${scrapbook.title}
${scrapbook.subtitle}

${scrapbook.story}

Top Highlights:
${scrapbook.highlights.map((h) => "• $h").join("\n")}

Shared with ❤️ from CoCircle
https://cocircle.mahato.in
''';
                            await Clipboard.setData(ClipboardData(text: shareText));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Story copied to clipboard!'),
                                  backgroundColor: Color(0xFF8B5CF6),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                            try {
                              await SharePlus.instance.share(
                                ShareParams(
                                  text: shareText,
                                  subject: scrapbook.title,
                                ),
                              );
                            } catch (e) {
                              debugPrint('Share memory error: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.share),
                          label: const Text('Share Scrapbook Story', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(tripMemoriesProvider(widget.tripId));
    final scrapbookAsync = ref.watch(tripScrapbookProvider(widget.tripId));
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner & Recap Generator Action
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                elevation: 0,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.photo_library, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Magic Memory',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Shared group album & AI trip recap',
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isGeneratingScrapbook
                            ? null
                            : () {
                                if (scrapbookAsync.value != null) {
                                  _showScrapbookDialog(scrapbookAsync.value!);
                                } else {
                                  _generateScrapbook();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _isGeneratingScrapbook
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.auto_awesome, size: 16),
                        label: Text(
                          scrapbookAsync.value != null ? 'Recap 📖' : 'Recap ✨',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Categories Filter Row
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['id'];

                  return ChoiceChip(
                    avatar: Text(cat['icon']!),
                    label: Text(cat['label']!),
                    selected: isSelected,
                    selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => _selectedCategory = cat['id']!),
                  );
                },
              ),
            ),
          ),

          // Memory Items Grid / List
          memoriesAsync.when(
            data: (memories) {
              final filtered = _selectedCategory == 'all'
                  ? memories
                  : memories.where((m) => m.category == _selectedCategory).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_camera_back_outlined, size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'No memories in this category yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Upload group photos and sunset moments!',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _openAddMemorySheet(context),
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Add Group Memory'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filtered[index];
                      final isLiked = currentUserId != null && item.likes.contains(currentUserId);

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo
                            Container(
                              height: 220,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: Image.network(
                                item.mediaUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.deepPurple.shade100,
                                  child: const Center(
                                    child: Icon(Icons.image, size: 50, color: Colors.deepPurple),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.category.toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF8B5CF6),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (item.locationName != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                            const SizedBox(width: 2),
                                            Text(
                                              item.locationName!,
                                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.caption,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'By ${item.uploaderName} • ${DateFormat.MMMd().format(item.uploadedAt)}',
                                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isLiked ? Icons.favorite : Icons.favorite_border,
                                              color: isLiked ? Colors.red : Colors.grey,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              if (currentUserId != null) {
                                                ref.read(memoryRepositoryProvider).toggleLike(
                                                  widget.tripId,
                                                  item.id,
                                                  currentUserId,
                                                );
                                              }
                                            },
                                          ),
                                          if (item.likes.isNotEmpty)
                                            Text(
                                              '${item.likes.length}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error loading memories: $e'))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMemorySheet(context),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
