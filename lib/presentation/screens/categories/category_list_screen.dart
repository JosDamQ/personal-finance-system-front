import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_api_service.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/sync_status_widget.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final CategoryApiService _categoryService = CategoryApiService();
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final categories = await _categoryService.getCategories();

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();

        // Provide more user-friendly error messages
        if (errorMessage.contains('FormatException') ||
            errorMessage.contains('DOCTYPE html')) {
          errorMessage =
              'Backend server is not running or categories endpoint is not available.\n\nPlease make sure the backend server is running on http://localhost:3000';
        } else if (errorMessage.contains('SocketException') ||
            errorMessage.contains('No internet connection')) {
          errorMessage =
              'Cannot connect to server. Please check your internet connection and make sure the backend is running.';
        } else if (errorMessage.contains('TimeoutException')) {
          errorMessage =
              'Request timed out. Please check your connection and try again.';
        }

        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeDefaultCategories() async {
    try {
      setState(() => _isLoading = true);

      // Call the initialize endpoint
      await _categoryService.createDefaultCategories();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default categories created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCategories(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        String errorMessage = 'Error creating default categories';

        // Parse ApiException to get the actual error message
        if (e.toString().contains('ApiException:')) {
          final parts = e.toString().split('ApiException: ');
          if (parts.length > 1) {
            final messagePart = parts[1].split(' (Status:')[0];
            errorMessage = messagePart;
          }
        } else {
          errorMessage = 'Error creating default categories: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'All expenses in this category will be moved to the default category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _categoryService.deleteCategory(category.id);
        _loadCategories(); // Refresh the list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "${category.name}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Error deleting category';

          // Parse ApiException to get the actual error message
          if (e.toString().contains('ApiException:')) {
            // Extract the message part after "ApiException: "
            final parts = e.toString().split('ApiException: ');
            if (parts.length > 1) {
              final messagePart = parts[1].split(' (Status:')[0];
              errorMessage = messagePart;
            }
          } else if (e.toString().contains('Cannot delete default category')) {
            errorMessage =
                'Cannot delete the default category. Please set another category as default first.';
          } else if (e.toString().contains('Category not found')) {
            errorMessage = 'Category not found or already deleted.';
          } else {
            errorMessage = 'Error deleting category: ${e.toString()}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      drawer: const AppDrawer(),
      body: _buildBody(),
      floatingActionButton: Stack(
        children: [
          // Back to Dashboard button (left side)
          Positioned(
            left: 30,
            bottom: 0,
            child: FloatingActionButton(
              heroTag: "back_button",
              onPressed: () => context.go(AppRouter.dashboard),
              backgroundColor: Colors.grey[600],
              child: const Icon(Icons.home),
            ),
          ),
          // Add Category button (right side)
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              heroTag: "add_button",
              onPressed: () async {
                final result = await context.push(AppRouter.categoryForm);
                if (result == true) {
                  _loadCategories(); // Refresh if category was added
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading categories',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Categories Yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first category to start organizing your expenses',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await context.push(AppRouter.categoryForm);
                    if (result == true) {
                      _loadCategories();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Category'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _initializeDefaultCategories,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Add Defaults'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _parseColor(category.color),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(category.icon, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          category.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (category.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            if (category.syncStatus != null)
              SyncStatusWidget(status: category.syncStatus!),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                final result = await context.push(
                  '${AppRouter.categoryForm}?id=${category.id}',
                );
                if (result == true) {
                  _loadCategories();
                }
                break;
              case 'delete':
                if (!category.isDefault) {
                  _deleteCategory(category);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot delete default category'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (!category.isDefault)
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        onTap: () async {
          final result = await context.push(
            '${AppRouter.categoryForm}?id=${category.id}',
          );
          if (result == true) {
            _loadCategories();
          }
        },
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      // Remove # if present and ensure it's a valid hex color
      String cleanColor = colorString.replaceAll('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      }
      return Colors.blue; // Default color
    } catch (e) {
      return Colors.blue; // Default color if parsing fails
    }
  }
}
