import '../../common_widgets/action_widget.dart';
import '../../common_widgets/app_search_bar.dart';
import '/src/network/ui/list/cubit/network_list_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Enum representing the types of network actions available
enum NetworkActionType {
  method,
  status,
  clear,
}

/// Abstract class providing action models for network operations
class NetworkAction {
  /// Creates a filter action model with method and status filters
  static ActionModel get filterModel {
    return ActionModel(
      icon: Icons.filter_alt_outlined,
      actions: const [
        PopupAction(
          id: NetworkActionType.method,
          name: "Method",
          subActions: [
            PopupAction(id: 'get', name: "GET"),
            PopupAction(id: 'post', name: "POST"),
            PopupAction(id: 'put', name: "PUT"),
            PopupAction(id: 'delete', name: "DELETE"),
            PopupAction(id: 'option', name: "OPTION"),
          ],
        ),
        PopupAction(
          id: NetworkActionType.status,
          name: "Status",
          subActions: [
            PopupAction(id: 'success', name: "Success"),
            PopupAction(id: 'error', name: "Error"),
          ],
        ),
      ],
    );
  }

  /// Creates a menu action model with options like Clear
  static ActionModel<NetworkActionType> get menuModel {
    return ActionModel(
      icon: Icons.more_vert,
      actions: const [
        PopupAction(
          id: NetworkActionType.clear,
          name: "Clear",
        ),
      ],
    );
  }
}

/// AppBar widget for the network call list screen
class NetworkCallAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Constructor for mobile version
  const NetworkCallAppBar({
    super.key,
    this.hasBottom = false,
    required this.cubit,
  }) : isDesktop = false;

  /// Constructor for desktop version
  const NetworkCallAppBar.desktop({
    super.key,
    this.hasBottom = false,
    required this.cubit,
  }) : isDesktop = true;

  final bool hasBottom;
  final bool isDesktop;
  final NetworkListScreenCubit cubit;

  @override
  State<NetworkCallAppBar> createState() => _NetworkCallAppBarState();

  @override
  Size get preferredSize => hasBottom
      ? Size.fromHeight(isDesktop ? 74 : kToolbarHeight + 50)
      : Size.fromHeight(isDesktop ? 40 : kToolbarHeight);
}

class _NetworkCallAppBarState extends State<NetworkCallAppBar> {
  late final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openSheet() {
    FiltersBottomSheet.open(context, widget.cubit);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      leading: _buildLeading(),
      title: _buildSearchBar(),
      actions: _buildActions(),
      bottom: widget.cubit.state.selectedMethods.isEmpty
          ? const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: SizedBox.shrink(),
        )
          : PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: _AppliedMethodsListView(
          onTap: widget.cubit.onMethodSelected,
          selectedMethods: widget.cubit.state.selectedMethods,
          onRemove: widget.cubit.onMethodRemoved,
            ),
          ),
        ),
    );
  }

  /// Build the leading widget (back button on mobile)
  Widget? _buildLeading() {
    if (widget.isDesktop) return null;

    return BackButton(
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  /// Build the search bar widget
  Widget _buildSearchBar() {
    return AppSearchBar(
      controller: _controller,
      focusNode: _focusNode,
      isDesktop: widget.isDesktop,
      onChanged: widget.cubit.onQueryChanged,
    );
  }

  /// Build the action buttons
  List<Widget> _buildActions() {
    return [
      IconButton(
        onPressed: _openSheet,
        icon: const Icon(Icons.filter_alt_outlined),
      ),
    ];
  }
}

/// Widget displaying available method filters in a horizontal list
class _MethodsListView extends StatelessWidget {
  const _MethodsListView({
    required this.onTap,
    required this.selectedMethods,
    required this.onRemove,
  });

  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final Set<String> selectedMethods;

  static const List<String> methodsList = [
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'OPTION'
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        scrollDirection: Axis.horizontal,
        itemCount: methodsList.length,
        itemBuilder: (context, index) {
          final String title = methodsList[index];
          return _FilterTile(
            title: title,
            isActive: selectedMethods.contains(title),
            onTap: () => onTap(title),
            onRemove: () => onRemove(title),
          );
        },
      ),
    );
  }
}

/// Widget displaying currently applied method filters
class _AppliedMethodsListView extends StatelessWidget {
  const _AppliedMethodsListView({
    required this.onTap,
    required this.selectedMethods,
    required this.onRemove,
  });

  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final Set<String> selectedMethods;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        scrollDirection: Axis.horizontal,
        itemCount: selectedMethods.length,
        itemBuilder: (context, index) {
          final String title = selectedMethods.elementAt(index);
          return _FilterTile(
            title: title,
            isActive: true,
            onTap: () => onTap(title),
            onRemove: () => onRemove(title),
            activeBackgroundColor: Theme.of(context).colorScheme.surface,
            activeTextColor: Colors.black,
          );
        },
      ),
    );
  }
}

/// Bottom sheet for selecting filters
class FiltersBottomSheet extends StatelessWidget {
  const FiltersBottomSheet({
    super.key,
    required this.cubit,
  });

  final NetworkListScreenCubit cubit;

  /// Open the filters bottom sheet
  static Future<void> open(
      BuildContext context, NetworkListScreenCubit cubit) async {
    await showModalBottomSheet(
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      context: context,
      builder: (context) {
        return FiltersBottomSheet(cubit: cubit);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Method', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          BlocBuilder<NetworkListScreenCubit, NetworkListScreenState>(
            bloc: cubit, // Directly specify the cubit
            builder: (context, state) {
              return _MethodsListView(
                onTap: cubit.onMethodSelected,
                selectedMethods: state.selectedMethods,
                onRemove: cubit.onMethodRemoved,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual filter tile widget
class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.onRemove,
    this.activeTextColor,
    this.activeBackgroundColor,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final Color? activeTextColor;
  final Color? activeBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topLeft,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: _buildDecoration(themeData),
          child: _buildContent(themeData),
        ),
      ),
    );
  }

  /// Build the container decoration based on state
  BoxDecoration _buildDecoration(ThemeData themeData) {
    Color backgroundColor = themeData.colorScheme.surface;

    if (isActive) {
      backgroundColor = activeBackgroundColor ??
          themeData.appBarTheme.backgroundColor ??
          themeData.colorScheme.primary;
    }

    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(color: themeData.colorScheme.onSurface),
      borderRadius: BorderRadius.circular(50),
    );
  }

  /// Build the tile content based on active state
  Widget _buildContent(ThemeData themeData) {
    Color textColor = themeData.colorScheme.onSurface;

    if (isActive) {
      textColor = activeTextColor ?? themeData.colorScheme.surface;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: textColor)),
          InkWell(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(title);
  }
}
