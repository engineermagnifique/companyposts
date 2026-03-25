import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;
  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _authorCtrl;
  String _category = Post.categories.first;
  String _status = 'draft';
  bool _saving = false;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl =
        TextEditingController(text: widget.post?.title ?? '');
    _contentCtrl =
        TextEditingController(text: widget.post?.content ?? '');
    _authorCtrl =
        TextEditingController(text: widget.post?.author ?? '');
    _category = widget.post?.category ?? Post.categories.first;
    _status = widget.post?.status ?? 'draft';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    if (_isEditing) {
      final updated = widget.post!.copyWith(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        category: _category,
        status: _status,
        updatedAt: now,
      );
      await DatabaseHelper.instance.updatePost(updated);
    } else {
      final post = Post(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        category: _category,
        status: _status,
        createdAt: now,
        updatedAt: now,
      );
      await DatabaseHelper.instance.createPost(post);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? '✅  Post updated successfully!'
              : '✅  Post created successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          GradientHeader(
            title: _isEditing ? 'Edit Post' : 'New Post',
            subtitle: _isEditing
                ? 'Update post details'
                : 'Fill in the details below',
            showBack: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _SectionLabel(label: 'Post Title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 120,
                      decoration: const InputDecoration(
                        hintText: 'Enter an engaging title...',
                        prefixIcon: Icon(Icons.title_rounded,
                            color: AppColors.primary),
                        counterText: '',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 18),

                    // Author
                    _SectionLabel(label: 'Author'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _authorCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Your name...',
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            color: AppColors.primary),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Author is required'
                          : null,
                    ),
                    const SizedBox(height: 18),

                    // Category & Status Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(label: 'Category'),
                              const SizedBox(height: 8),
                              _StyledDropdown<String>(
                                value: _category,
                                items: Post.categories,
                                labelBuilder: (v) => v,
                                icon: Icons.folder_outlined,
                                onChanged: (v) =>
                                    setState(() => _category = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(label: 'Status'),
                              const SizedBox(height: 8),
                              _StyledDropdown<String>(
                                value: _status,
                                items: Post.statuses,
                                labelBuilder: (v) =>
                                    v[0].toUpperCase() + v.substring(1),
                                icon: Icons.flag_outlined,
                                onChanged: (v) =>
                                    setState(() => _status = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Status preview
                    _StatusPreviewBar(status: _status),
                    const SizedBox(height: 18),

                    // Content
                    _SectionLabel(label: 'Content'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contentCtrl,
                      minLines: 6,
                      maxLines: 14,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText:
                            'Write your post content here...',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 100),
                          child: Icon(Icons.notes_rounded,
                              color: AppColors.primary),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Content is required'
                          : null,
                    ),
                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: _saving
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: _save,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isEditing
                                              ? Icons.check_circle_outline_rounded
                                              : Icons.save_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isEditing
                                              ? 'Save Changes'
                                              : 'Publish Post',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(
                                color: AppColors.divider, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final IconData icon;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary, size: 20),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(labelBuilder(item)),
                    ],
                  ),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _StatusPreviewBar extends StatelessWidget {
  final String status;
  const _StatusPreviewBar({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String desc;

    switch (status) {
      case 'published':
        color = AppColors.success;
        icon = Icons.public_rounded;
        desc = 'Visible to all team members';
        break;
      case 'archived':
        color = AppColors.textSecondary;
        icon = Icons.archive_rounded;
        desc = 'Archived and hidden from main feed';
        break;
      default:
        color = AppColors.warning;
        icon = Icons.drafts_rounded;
        desc = 'Saved as draft, not yet published';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            desc,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
