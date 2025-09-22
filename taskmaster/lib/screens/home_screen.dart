import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/simple_task_provider.dart';
import '../providers/theme_provider.dart';
import '../core/theme/app_theme.dart';
import '../models/task_tab.dart';
import '../widgets/task_list.dart';
import '../widgets/task_filters.dart';
import '../widgets/task_stats_card.dart';
import 'add_task_screen.dart';
import 'advanced_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(context, isDark),
            _buildStatsSection(context),
            _buildTabBar(context),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            TaskList(tab: TaskTab.pending),
            TaskList(tab: TaskTab.completed),
            TaskList(tab: TaskTab.all),
          ],
        ),
      ),
      floatingActionButton: Consumer<SimpleTaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.totalTasks > 0) {
            return FloatingActionButton.extended(
              onPressed: () => _navigateToAddTask(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Task'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return SliverAppBar(
      expandedHeight: 0, // Disable expansion
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TaskMaster',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                    Consumer<SimpleTaskProvider>(
                  builder: (context, taskProvider, child) {
                        return Text(
                          '${taskProvider.totalTasks} tasks • ${taskProvider.completedTasksCount} completed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              onPressed: () => themeProvider.toggleTheme(),
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 24,
              ),
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            );
          },
        ),
        Consumer<SimpleTaskProvider>(
          builder: (context, taskProvider, child) {
            return IconButton(
              onPressed: () => taskProvider.toggleGroupByCategory(),
              icon: Icon(
                taskProvider.groupByCategory ? Icons.view_agenda_rounded : Icons.view_stream_rounded,
                size: 24,
              ),
              tooltip: taskProvider.groupByCategory ? 'Ungroup by Category' : 'Group by Category',
            );
          },
        ),
        IconButton(
          onPressed: () => _navigateToAdvancedSearch(context),
          icon: const Icon(Icons.search_rounded, size: 24),
          tooltip: 'Advanced Search',
        ),
        IconButton(
          onPressed: () => _showFiltersBottomSheet(context),
          icon: const Icon(Icons.filter_list_rounded, size: 24),
          tooltip: 'Filters',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<SimpleTaskProvider>(
        builder: (context, taskProvider, child) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.spacingM, AppTheme.spacingS, AppTheme.spacingM, AppTheme.spacingXS),
            child: TaskStatsCard(
              totalTasks: taskProvider.totalTasks,
              completedTasks: taskProvider.completedTasksCount,
              pendingTasks: taskProvider.pendingTasksCount,
              completionPercentage: taskProvider.completionPercentage,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.pending_actions_rounded),
                text: 'Pending',
              ),
              Tab(
                icon: Icon(Icons.check_circle_rounded),
                text: 'Completed',
              ),
              Tab(
                icon: Icon(Icons.list_rounded),
                text: 'All Tasks',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
  }

  void _navigateToAdvancedSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdvancedSearchScreen(),
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskFilters(),
    );
  }
}
