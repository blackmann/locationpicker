import 'dart:async';

import 'package:flutter/material.dart';
import 'package:place_picker/entities/search_bar_options_model.dart';
import 'package:place_picker/place_picker.dart';

/// Custom Search input field, showing the search and clear icons.
class SearchInput extends StatefulWidget {
  final ValueChanged<String> onSearchInput;
  final SearchBarOptions? searchBarOptions;

  SearchInput(this.onSearchInput, {this.searchBarOptions});

  @override
  State<StatefulWidget> createState() => SearchInputState();
}

class SearchInputState extends State<SearchInput> {
  TextEditingController editController = TextEditingController();

  Timer? debouncer;

  bool hasSearchEntry = false;

  SearchInputState();

  @override
  void initState() {
    super.initState();
    this.editController.addListener(this.onSearchInputChange);
  }

  @override
  void dispose() {
    this.editController.removeListener(this.onSearchInputChange);
    this.editController.dispose();

    super.dispose();
  }

  void onSearchInputChange() {
    if (this.editController.text.isEmpty) {
      this.debouncer?.cancel();
      widget.onSearchInput(this.editController.text);
      return;
    }

    if (this.debouncer?.isActive ?? false) {
      this.debouncer!.cancel();
    }

    this.debouncer = Timer(Duration(milliseconds: 500), () {
      widget.onSearchInput(this.editController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Padding(
            padding: widget.searchBarOptions?.searchIconPadding ??
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: widget.searchBarOptions?.searchIcon ??
                Icon(Icons.search,
                    color: Theme.of(context).textTheme.bodyText1!.color),
          ),
          Expanded(
            child: TextField(
              decoration: widget.searchBarOptions?.inputDecoration ??
                  InputDecoration(
                      hintText: "Search place", border: InputBorder.none),
              controller: this.editController,
              onChanged: (value) {
                setState(() {
                  this.hasSearchEntry = value.isNotEmpty;
                });
              },
            ),
          ),
          if (this.hasSearchEntry)
            Padding(
              padding: widget.searchBarOptions?.clearTextIconPadding ??
                  EdgeInsets.zero,
              child: GestureDetector(
                onTap: () {
                  this.editController.clear();
                  setState(() {
                    this.hasSearchEntry = false;
                  });
                },
                child: widget.searchBarOptions?.clearTextIcon ??
                    Icon(
                      Icons.clear,
                    ),
              ),
            ),
        ],
      ),
      decoration: widget.searchBarOptions?.decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).canvasColor,
          ),
    );
  }
}
