import 'package:flutter/material.dart';

class SearchBarOptions {
  ///To Wrap search bar with padding
  final EdgeInsetsGeometry? padding;

  ///Search icon padding
  final EdgeInsetsGeometry? searchIconPadding;

  ///clear Text button icon padding
  final EdgeInsetsGeometry? clearTextIconPadding;

  ///A background color to set if the search bar hasPadding
  final Color? backgroundColor;

  ///elavtion of Searchbar in case for example you add a transparetnt background color to searchbar
  final double? elevation;

  ///This is used to add extra space on top of autosuggestion.
  ///This is usefull for example when you use PlacePicker inside another Scaffold which has appbar
  ///
  ///Simple Usage: `overlyTopPadding: MediaQuery.of(context).padding.top + kToolbarHeight,`
  final double? overlyTopPadding;

  ///Search Bar height,
  final double? height;

  ///Icon for SearchBar
  final Widget? searchIcon;

  ///Icon for clear text button
  final Widget? clearTextIcon;

  ///Decoration to apply to search input
  final InputDecoration? inputDecoration;

  ///Decoration for searchbar
  final Decoration? decoration;

  const SearchBarOptions({
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.clearTextIcon,
    this.overlyTopPadding,
    this.searchIcon,
    this.inputDecoration,
    this.searchIconPadding,
    this.decoration,
    this.height,
    this.clearTextIconPadding,
  });
}
