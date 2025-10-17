import 'package:flutter/material.dart';

class AutocompleteTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final List<String> suggestions;
  final bool isReadOnly;

  const AutocompleteTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.suggestions,
    this.isReadOnly = false,
  });

  @override
  State<AutocompleteTextField> createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width * 0.9,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 50.0),
          child: Material(
            elevation: 4.0,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _getFilteredSuggestions().length,
                itemBuilder: (context, index) {
                  final suggestion = _getFilteredSuggestions()[index];
                  return ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      widget.controller.text = suggestion;
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<String> _getFilteredSuggestions() {
    final text = widget.controller.text.toLowerCase();
    if (text.isEmpty) return [];

    return widget.suggestions.where((suggestion) {
      return suggestion.toLowerCase().contains(text);
    }).toList();
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        readOnly: widget.isReadOnly,
        onChanged: (value) {
          if (_focusNode.hasFocus) {
            _showOverlay();
            _overlayEntry?.markNeedsBuild();
          }
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.label,
          hintText: widget.hint,
        ),
      ),
    );
  }
}
