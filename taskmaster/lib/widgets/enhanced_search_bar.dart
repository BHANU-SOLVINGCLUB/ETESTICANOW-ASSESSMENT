import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../models/task.dart';

class EnhancedSearchBar extends StatefulWidget {
  final String initialQuery;
  final Function(String) onSearchChanged;
  final Function(String) onSearchSubmitted;
  final List<Task> allTasks;
  final VoidCallback onClear;
  final bool showSuggestions;

  const EnhancedSearchBar({
    super.key,
    required this.initialQuery,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.allTasks,
    required this.onClear,
    this.showSuggestions = true,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounceTimer;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && widget.showSuggestions;
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(query);
      _updateSuggestions(query);
    });
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final suggestions = <String>{};
    
    // Add task titles that match
    for (final task in widget.allTasks) {
      if (task.title.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(task.title);
      }
      if (task.description.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(task.description);
      }
      if (task.category != null && 
          task.category!.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(task.category!);
      }
    }

    setState(() {
      _suggestions = suggestions.take(5).toList();
    });
  }

  void _onSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    _focusNode.unfocus();
    widget.onSearchSubmitted(suggestion);
    setState(() {
      _showSuggestions = false;
    });
  }

  void _onSearchSubmitted(String query) {
    _focusNode.unfocus();
    widget.onSearchSubmitted(query);
    setState(() {
      _showSuggestions = false;
    });
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    widget.onClear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            decoration: InputDecoration(
              hintText: 'Search tasks, categories, or descriptions...',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _suggestions.map((suggestion) {
                return InkWell(
                  onTap: () => _onSuggestionTap(suggestion),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
