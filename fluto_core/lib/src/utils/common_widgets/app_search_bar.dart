import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.isDesktop = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isDesktop ? 28 : null,
      child: DefaultSelectionStyle(
        cursorColor: Colors.white,
        child: CupertinoSearchTextField(
          
          // padding: isDesktop
          //     ? EdgeInsets.zero
          //     : const EdgeInsetsDirectional.fromSTEB(5.5, 8, 5.5, 8),
          // style: isDesktop
          //     ? Theme.of(context).textTheme.labelSmall
          //     : Theme.of(context).textTheme.labelLarge,
          // style: TextStyle(color: Colors.white),
          // placeholderStyle: Theme.of(context)
          //         .textTheme
          //         .labelMedium?.copyWith(color: Colors.white),

          controller: controller,
          focusNode: focusNode,
          // itemSize: isDesktop ? 16 : 20,

          prefixInsets: isDesktop
              ? const EdgeInsetsDirectional.only(start: 8, end: 4, bottom: 2)
              : const EdgeInsetsDirectional.fromSTEB(6, 0, 0, 3),
          onChanged: (value) {
            onChanged.call(value);
          },
          backgroundColor: Color.fromARGB(255, 149, 18, 15),
          style: TextStyle(color: Colors.white), // Set the text color to white
          placeholderStyle: TextStyle(color: Colors.white70), // Set the placeholder text color to white with some transparency
          prefixIcon: Icon(CupertinoIcons.search, color: Colors.white), // Customize the search icon color
          suffixIcon: Icon(CupertinoIcons.clear_thick_circled, color: Colors.white), // Customize the cut icon color
        ),
      ),
    );
  }
}
