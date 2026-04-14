import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'treehole_post_page.dart';
import 'treehole_detail_page.dart';
import 'treehole_mine_page.dart';
import 'treehole_models.dart';
import 'treehole_service.dart';
import 'widgets/treehole_card.dart';

/// 树洞浏览页
class TreeholePage extends StatefulWidget {
  const TreeholePage({super.key});

  @override
  State<TreeholePage> createState() => _TreeholePageState();
}

class _TreeholePageState extends State<TreeholePage> {
  TreeholePost? _currentPost;
  String _selectedTag = TreeholeTags.all;
  bool _isLoading = false;
  bool _hasNoMore = false;

  @override
  void initState() {
    super.initState();
    _loadRandomPost();
  }

  Future<void> _loadRandomPost() async {
    if (_isLoading) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先登录')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _hasNoMore = false;
    });

    try {
      final tag = _selectedTag == TreeholeTags.all ? null : _selectedTag;
      final post = await TreeholeService.getRandomPost(tag: tag);

      if (mounted) {
        setState(() {
          _currentPost = post;
          _hasNoMore = post == null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onTagChanged(String tag) {
    setState(() {
      _selectedTag = tag;
    });
    _loadRandomPost();
  }

  void _onPostTap() {
    if (_currentPost == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreeholeDetailPage(postId: _currentPost!.id),
      ),
    );
  }

  void _onCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TreeholePostPage(),
      ),
    ).then((_) {
      _loadRandomPost();
    });
  }

  void _onMyPosts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TreeholeMinePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('树洞'),
        actions: [
          TextButton(
            onPressed: _onMyPosts,
            child: const Text('我的'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTagBar(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTagBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: TreeholeTags.allTags.length,
        itemBuilder: (context, index) {
          final tag = TreeholeTags.allTags[index];
          final isSelected = tag == _selectedTag;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _onTagChanged(tag);
                }
              },
              selectedColor: AppColors.primaryLight,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasNoMore || _currentPost == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _hasNoMore ? '今天没有更多树洞了~' : '暂无树洞',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '去说点什么吧',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Dismissible(
              key: Key(_currentPost!.id.toString()),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                _loadRandomPost();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TreeholeCard(
                  post: _currentPost!,
                  onTap: _onPostTap,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              Text(
                '左滑或右滑换一个',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _loadRandomPost,
                icon: const Icon(Icons.refresh),
                label: const Text('换一个'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
