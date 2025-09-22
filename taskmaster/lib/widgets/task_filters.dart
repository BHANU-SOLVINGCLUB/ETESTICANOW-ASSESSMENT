import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/simple_task_provider.dart';
import '../models/task_sort_option.dart';

class TaskFilters extends StatefulWidget {
  const TaskFilters({super.key});

  @override
  State<TaskFilters> createState() => _TaskFiltersState();
}

class _TaskFiltersState extends State<TaskFilters> {
  late TextEditingController _searchController;
  String? _selectedCategory;
  TaskSortOption _selectedSortOption = TaskSortOption.createdDate;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
        return Consumer<SimpleTaskProvider>(
          builder: (context, taskProvider, child) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchSection(),
                            const SizedBox(height: 24),
                            _buildCategorySection(taskProvider),
                            const SizedBox(height: 24),
                            _buildSortSection(),
                            const SizedBox(height: 24),
                            _buildShowCompletedSection(),
                            const SizedBox(height: 32),
                            _buildActionButtons(taskProvider),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filters & Search',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Tasks',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by title, description, or category...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(SimpleTaskProvider taskProvider) {
    final categories = taskProvider.categories;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildCategoryChip('All', null),
            ...categories.map((category) => _buildCategoryChip(category, category)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? value : null;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskSortOption>(
          value: _selectedSortOption,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                _selectedSortOption = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildShowCompletedSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Show Completed Tasks',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Switch(
          value: _showCompleted,
          onChanged: (value) {
            setState(() {
              _showCompleted = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(SimpleTaskProvider taskProvider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              taskProvider.clearFilters();
              _searchController.clear();
              setState(() {
                _selectedCategory = null;
                _selectedSortOption = TaskSortOption.createdDate;
                _showCompleted = false;
              });
            },
            child: const Text('Clear All'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              taskProvider.searchTasks(_searchController.text);
              if (_selectedCategory != null) {
                taskProvider.filterByCategory(_selectedCategory!);
              }
              taskProvider.sortTasks(_selectedSortOption);
              if (_showCompleted != taskProvider.showCompleted) {
                taskProvider.toggleShowCompleted();
              }
              Navigator.of(context).pop();
            },
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }
}
