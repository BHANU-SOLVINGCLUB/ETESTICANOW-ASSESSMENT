import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/simple_task_provider.dart';
import '../models/task.dart';
import '../models/task_sort_option.dart';
import '../widgets/enhanced_search_bar.dart';
import '../widgets/task_tile.dart';
import 'edit_task_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  TaskPriority? _selectedPriority;
  TaskSortOption _sortOption = TaskSortOption.createdDate;
  bool _showCompleted = true;
  bool _showOverdue = false;
  List<Task> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Advanced Search',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear all filters',
          ),
        ],
      ),
      body: Consumer<SimpleTaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              _buildSearchSection(taskProvider),
              _buildFilterSection(),
              _buildResultsSection(taskProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(SimpleTaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: EnhancedSearchBar(
        initialQuery: _searchQuery,
        allTasks: taskProvider.tasks,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
          _performSearch(context);
        },
        onSearchSubmitted: (query) {
          setState(() {
            _searchQuery = query;
          });
          _performSearch(context);
        },
        onClear: () {
          setState(() {
            _searchQuery = '';
            _searchResults = [];
          });
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCategoryFilter(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriorityFilter(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSortDropdown(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToggleButtons(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<SimpleTaskProvider>(
      builder: (context, taskProvider, child) {
        final categories = taskProvider.categories;
        
        return DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All Categories'),
            ),
            ...categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
            _performSearch(context);
          },
        );
      },
    );
  }

  Widget _buildPriorityFilter() {
    return DropdownButtonFormField<TaskPriority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All Priorities'),
        ),
        ...TaskPriority.values.map((priority) {
          return DropdownMenuItem(
            value: priority,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(priority.displayName),
              ],
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPriority = value;
        });
        _performSearch(context);
      },
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<TaskSortOption>(
      value: _sortOption,
      decoration: InputDecoration(
        labelText: 'Sort by',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      items: TaskSortOption.values.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _sortOption = value;
          });
          _performSearch(context);
        }
      },
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      children: [
        Expanded(
          child: FilterChip(
            label: const Text('Completed'),
            selected: _showCompleted,
            onSelected: (selected) {
              setState(() {
                _showCompleted = selected;
              });
              _performSearch(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterChip(
            label: const Text('Overdue'),
            selected: _showOverdue,
            onSelected: (selected) {
              setState(() {
                _showOverdue = selected;
              });
              _performSearch(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(SimpleTaskProvider taskProvider) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Results (${_searchResults.length})',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (_isSearching)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _searchResults.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final task = _searchResults[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskTile(
                            task: task,
                            onTap: () => _editTask(task),
                            onToggle: () => _toggleTask(taskProvider, task),
                            onEdit: () => _editTask(task),
                            onDelete: () => _deleteTask(taskProvider, task),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Start searching...' : 'No tasks found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Enter a search term to find tasks'
                : 'Try adjusting your filters or search terms',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _performSearch(BuildContext context) {
    final taskProvider = Provider.of<SimpleTaskProvider>(context, listen: false);
    
    setState(() {
      _isSearching = true;
    });

    // Simulate search delay for better UX
    Future.delayed(const Duration(milliseconds: 100), () {
      List<Task> results = taskProvider.advancedSearch(
        query: _searchQuery,
        category: _selectedCategory,
        priority: _selectedPriority,
        isCompleted: _showCompleted ? null : false,
        isOverdue: _showOverdue,
        sortOption: _sortOption,
      );


      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _selectedPriority = null;
      _sortOption = TaskSortOption.createdDate;
      _showCompleted = true;
      _showOverdue = false;
      _searchResults = [];
    });
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  void _editTask(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    );
  }

  void _toggleTask(SimpleTaskProvider taskProvider, Task task) {
    taskProvider.toggleTaskCompletion(task.id);
  }

  void _deleteTask(SimpleTaskProvider taskProvider, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () {
              taskProvider.deleteTask(task.id);
              Navigator.of(context).pop();
              _performSearch(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
