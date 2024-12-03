import 'package:fluto_core/src/network/ui/filters/network_filters.dart';
import 'package:fluto_core/src/utils/common_widgets/app_adaptive_dialog.dart';
import 'package:fluto_core/src/utils/common_widgets/conditional_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/common_widgets/action_widget.dart';
import '../../../../utils/common_widgets/app_search_bar.dart';

enum NetworkActionType {
  method,
  status,
  share,
  clear,
}

abstract class NetworkAction {
  static ActionModel get filterModel {
    return ActionModel(
      icon: Icons.filter_alt_outlined,
      actions: const [
        PopupAction(
          id: NetworkActionType.method,
          name: "Method",
          subActions: [
            PopupAction(
              id: 'get',
              name: "GET",
            ),
            PopupAction(
              id: 'post',
              name: "POST",
            ),
            PopupAction(
              id: 'put',
              name: "PUT",
            ),
            PopupAction(
              id: 'delete',
              name: "DELETE",
            ),
            PopupAction(
              id: 'option',
              name: "OPTION",
            ),
          ],
        ),
        PopupAction(
          id: NetworkActionType.status,
          name: "Status",
          subActions: [
            PopupAction(
              id: 'success',
              name: "Success",
            ),
            PopupAction(
              id: 'error',
              name: "Error",
            ),
          ],
        ),
      ],
    );
  }

  static ActionModel<NetworkActionType> get menuModel {
    return ActionModel(
      icon: Icons.more_vert,
      actions: const [
        PopupAction(
          id: NetworkActionType.share,
          name: "Share",
        ),
        PopupAction(
          id: NetworkActionType.clear,
          name: "Clear",
        ),
      ],
    );
  }
}

class NetworkCallAppBar extends StatefulWidget implements PreferredSizeWidget {
  const NetworkCallAppBar({super.key, this.hasBottom = false, required this.filters}) : isDesktop = false;

  const NetworkCallAppBar.desktop({super.key, this.hasBottom = false, required this.filters}) : isDesktop = true;

  final bool hasBottom;
  final bool isDesktop;
  final NetworkFilters filters;

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
  void initState() {
    super.initState();
  }

  void _openSheet() {
    FiltersBottomSheet.open(context, widget.filters);
  }

  @override
  Widget build(BuildContext context) {
    // final networkListBloc = context.read<NetworksListBloc>();

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      leading: widget.isDesktop
          ? null
          : BackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
      title: AppSearchBar(
        controller: _controller,
        focusNode: _focusNode,
        isDesktop: widget.isDesktop,
        onChanged: widget.filters.onQueryChanged,
      ),
      actions: [
        IconButton(
          onPressed: _openSheet,
          icon: const Icon(Icons.filter_alt_outlined),
        ),
        // AppBarActionWidget(
        //   actionModel: NetworkAction.filterModel,
        //   // selectedActions: networkListBloc.state.filters,

        //   onItemSelected: (value) {
        //     // networkListBloc.add(NetworkLogsFilterAdded(action: value));
        //   },
        //   // selected: networkListBloc.state.filters.isNotEmpty,
        // ),
        AppBarActionWidget<NetworkActionType>(
          actionModel: NetworkAction.menuModel,
          onItemSelected: (value) {
            if (value.id == NetworkActionType.share) {
              // networkListBloc.add(const ShareNetworkLogsClicked());
            } else if (value.id == NetworkActionType.clear) {
              AppAdaptiveDialog.show(
                context,
                tag: 'network_calls',
                title: 'Clear Network Call Logs?',
                body: 'Are you sure you want to clear all network call logs? This will clear up the list.',
                onPositiveActionClick: () {
                  // networkListBloc.add(const ClearNetworkLogsClicked());
                },
              );
            }
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(widget.filters.selectedMethods.isNotEmpty ? 30 : 0),
        child: Visibility(
          visible: widget.filters.selectedMethods.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: ListenableBuilder(
              listenable: widget.filters,
              builder: (context, child) {
                return _AppliedMethodsListView(
                  onTap: widget.filters.onMethodSelected,
                  selectedMethods: widget.filters.selectedMethods,
                  onRemove: widget.filters.onMethodRemoved,
                );
              },
            ),
          ),
        ),
      ),
      // bottom: widget.hasBottom ? _BottomWidget(widget.isDesktop) : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }
}

// class _BottomWidget extends StatelessWidget implements PreferredSizeWidget {
//   const _BottomWidget(this.isDesktop);

//   final bool isDesktop;

//   @override
//   Size get preferredSize => const Size.fromHeight(30);

//   @override
//   Widget build(BuildContext context) {
//     return BlocSelector<NetworksListBloc, NetworksListState, List<PopupAction>>(
//       selector: (state) {
//         return state.filters;
//       },
//       builder: (context, filters) {
//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return SizedBox(
//               width: constraints.maxWidth - 10,
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: filters.map(
//                     (e) {
//                       return ConditionalWidget(
//                         condition: isDesktop,
//                         ifTrue: Transform(
//                           transform: Matrix4.identity()..scale(0.8),
//                           child: chipWidget(e, context),
//                         ),
//                         ifFalse: chipWidget(e, context),
//                       );
//                     },
//                   ).toList(),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Padding chipWidget(PopupAction<dynamic> e, BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 8),
//       child: Chip(
//         label: Text(e.name),
//         deleteIcon: Container(
//           height: 14,
//           width: 14,
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primary,
//             border: Border.all(),
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(Icons.close_rounded, size: 12),
//         ),
//         labelPadding: const EdgeInsetsDirectional.only(
//           start: 4,
//         ),
//         onDeleted: () {
//           context.read<NetworksListBloc>().add(
//                 NetworkLogsFilterRemoved(action: e),
//               );
//         },
//       ),
//     );
//   }
// }

class _MethodsListView extends StatelessWidget {
  const _MethodsListView({
    required this.onTap,
    required this.selectedMethods,
    required this.onRemove,
  });

  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final Iterable<String> selectedMethods;

  static const List<String> methodsList = ['GET', 'POST', 'PUT', 'DELETE', 'OPTION'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 8),
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

class _AppliedMethodsListView extends StatelessWidget {
  const _AppliedMethodsListView({
    required this.onTap,
    required this.selectedMethods,
    required this.onRemove,
  });

  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final Iterable<String> selectedMethods;

  static const List<String> methodsList = ['GET', 'POST', 'PUT', 'DELETE', 'OPTION'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 8),
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

class FiltersBottomSheet extends StatelessWidget {
  const FiltersBottomSheet({
    super.key,
    required this.filters,
  });

  final NetworkFilters filters;

  static Future<void> open(BuildContext context, NetworkFilters filters) async {
    await showModalBottomSheet(
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      context: context,
      builder: (context) {
        return FiltersBottomSheet(filters: filters);
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
          ListenableBuilder(
            listenable: filters,
            builder: (context, child) {
              return _MethodsListView(
                onTap: filters.onMethodSelected,
                selectedMethods: filters.selectedMethods,
                onRemove: filters.onMethodRemoved,
              );
            },
          ),
        ],
      ),
    );
  }
}

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
    Widget child = Text(title);
    Color textColor = Theme.of(context).colorScheme.onSurface;
    Color backgroundColor = Theme.of(context).colorScheme.surface;

    if (isActive) {
      textColor = Theme.of(context).colorScheme.surface;
      backgroundColor = Theme.of(context).appBarTheme.backgroundColor!;

      if (activeTextColor != null) {
        textColor = activeTextColor!;
      }

      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor),
          ),
          InkWell(
            onTap: onRemove,
            child: Icon(
              size: 16,
              color: textColor,
              Icons.close_rounded,
            ),
          ),
        ],
      );
    }

    if (activeBackgroundColor != null) {
      backgroundColor = activeBackgroundColor!;
    }

    return InkWell(
      onTap: onTap,
      child: AnimatedSize(
        duration: Duration(milliseconds: 200),
        alignment: Alignment.topLeft,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            // color: isActive ? Theme.of(context).appBarTheme.backgroundColor : Theme.of(context).colorScheme.surface,
            color: backgroundColor,
            border: Border.all(color: Theme.of(context).colorScheme.onSurface),
            borderRadius: BorderRadius.circular(50),
          ),
          child: child,
        ),
      ),
    );
  }
}
