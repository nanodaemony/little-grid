import 'package:flutter/material.dart';
import 'big_wheel_view.dart';
import 'models/wheel_collection.dart';
import 'services/big_wheel_service.dart';
import 'pages/collection_list_page.dart';
import 'pages/collection_edit_page.dart';
import 'pages/option_list_page.dart';

/// Main page for Big Wheel with PageView for swiping between collections
class BigWheelPage extends StatefulWidget {
  const BigWheelPage({super.key});

  @override
  State<BigWheelPage> createState() => _BigWheelPageState();
}

class _BigWheelPageState extends State<BigWheelPage> {
  late PageController _pageController;
  List<WheelCollection> _collections = [];
  int _currentPage = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCollections();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCollections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await BigWheelService.initPresetCollections();
      final collections = await BigWheelService.getCollections();

      setState(() {
        _collections = collections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToCollectionEdit(WheelCollection collection) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionEditPage(collection: collection),
      ),
    );
    _loadCollections(); // Refresh after returning
  }

  void _navigateToOptionManagement(WheelCollection collection) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OptionListPage(collection: collection),
      ),
    );
    _loadCollections(); // Refresh after returning
  }

  void _navigateToCollectionList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CollectionListPage(),
      ),
    );
    _loadCollections(); // Refresh after returning
  }

  void _addNewCollection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CollectionEditPage(collection: null),
      ),
    );
    _loadCollections(); // Refresh after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('大转盘'),
        actions: [
          // Collection management button
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            onPressed: _navigateToCollectionList,
            tooltip: '管理转盘',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_collections.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // PageView for collections
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _collections.length,
            itemBuilder: (context, index) {
              return BigWheelView(
                collection: _collections[index],
                onEditCollection: () => _navigateToCollectionEdit(_collections[index]),
                onManageOptions: () => _navigateToOptionManagement(_collections[index]),
              );
            },
          ),
        ),

        // Page indicator
        _buildPageIndicator(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rotate_right,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            '还没有转盘',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮创建第一个转盘',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addNewCollection,
            icon: const Icon(Icons.add),
            label: const Text('创建转盘'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    if (_collections.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _collections.asMap().entries.map((entry) {
          final index = entry.key;
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 12 : 8,
            height: isActive ? 12 : 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_collections.isEmpty) {
      return FloatingActionButton.extended(
        onPressed: _addNewCollection,
        icon: const Icon(Icons.add),
        label: const Text('创建转盘'),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Secondary FAB - Collection list
        FloatingActionButton.small(
          onPressed: _navigateToCollectionList,
          heroTag: 'collection_list',
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          elevation: 4,
          child: const Icon(Icons.folder_outlined),
        ),
        const SizedBox(height: 8),
        // Primary FAB - Add new collection
        FloatingActionButton.extended(
          onPressed: _addNewCollection,
          heroTag: 'add_collection',
          icon: const Icon(Icons.add),
          label: const Text('新建'),
        ),
      ],
    );
  }
}
