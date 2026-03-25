import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Post> _posts = [];
  Map<String, int> _stats = {};
  bool _loading = true;
  String _filterStatus = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final filter = _filterStatus == 'All' ? null : _filterStatus;
    final search = _searchQuery.isEmpty ? null : _searchQuery;
    final posts =
        await DatabaseHelper.instance.readAllPosts(filterStatus: filter, search: search);
    final stats = await DatabaseHelper.instance.getStats();
    if (mounted) {
      setState(() {
        _posts = posts;
        _stats = stats;
        _loading = false;
      });
      _animCtrl.forward(from: 0);
    }
  }

  Future<void> _deletePost(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Post',
          style: TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${post.title}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && post.id != null) {
      await DatabaseHelper.instance.deletePost(post.id!);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post deleted successfully'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Header ──
          GradientHeader(
            title: 'Offline Posts',
            subtitle: '${_stats['total'] ?? 0} posts stored locally',
            trailing: GestureDetector(
              onTap: _loadData,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats Row ──
                    _StatsRow(stats: _stats),
                    const SizedBox(height: 20),

                    // ── Search ──
                    AppSearchBar(
                      controller: _searchCtrl,
                      onChanged: (v) {
                        setState(() => _searchQuery = v);
                        _loadData();
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Filters ──
                    FilterChipRow(
                      selected: _filterStatus,
                      onSelected: (v) {
                        setState(() => _filterStatus = v);
                        _loadData();
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Post List ──
                    if (_loading)
                      ...List.generate(
                          3, (_) => const ShimmerCard())
                    else if (_posts.isEmpty)
                      EmptyState(
                        message: 'No Posts Found',
                        subtitle: _searchQuery.isNotEmpty
                            ? 'Try a different search term.'
                            : 'Tap the button below to add your first post.',
                        onAction: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PostFormScreen()),
                          );
                          _loadData();
                        },
                      )
                    else
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          children: _posts
                              .map((post) => PostCard(
                                    post: post,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PostDetailScreen(post: post),
                                        ),
                                      );
                                      _loadData();
                                    },
                                    onEdit: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PostFormScreen(post: post),
                                        ),
                                      );
                                      _loadData();
                                    },
                                    onDelete: () => _deletePost(post),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── FAB ──
      floatingActionButton: GradientFAB(
        label: 'New Post',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostFormScreen()),
          );
          _loadData();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: [
        StatCard(
          label: 'Total',
          count: '${stats['total'] ?? 0}',
          icon: Icons.article_rounded,
          color: AppColors.primary,
        ),
        StatCard(
          label: 'Live',
          count: '${stats['published'] ?? 0}',
          icon: Icons.public_rounded,
          color: AppColors.success,
        ),
        StatCard(
          label: 'Draft',
          count: '${stats['draft'] ?? 0}',
          icon: Icons.drafts_rounded,
          color: AppColors.warning,
        ),
        StatCard(
          label: 'Archived',
          count: '${stats['archived'] ?? 0}',
          icon: Icons.archive_rounded,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
