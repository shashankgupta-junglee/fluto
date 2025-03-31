import '/src/network/infospect_network_call.dart';
import '/src/network/network_storage.dart';
import '/src/network/ui/details/bloc/interceptor_details_bloc.dart';
import '/src/network/ui/details/screen/interceptor_details_screen.dart';
import '/src/network/ui/list/components/network_call_item.dart';
import '/src/network/ui/list/cubit/network_list_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/network_call_app_bar.dart';
import 'dart:io';

/// Screen that displays a list of network calls with filtering capabilities.
class NetworksListScreen extends StatelessWidget {
  NetworksListScreen({
    super.key,
    required this.dataRouter,
  });
  final NetworkInspectorRouter dataRouter;

  late final NetworkListScreenCubit _cubit = NetworkListScreenCubit(
    storage: dataRouter,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkListScreenCubit, NetworkListScreenState>(
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: state.filteredCalls.isEmpty
              ? const _EmptyStateView()
              : _NetworkCallsListView(
                  filteredCalls: state.filteredCalls,
                  searchQuery: state.query,
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // Use appBarData from cubit state
    final appBarData = _cubit.state.appBarData;
    
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarData.height),
      child: NetworkCallAppBar(
        cubit: _cubit,
        hasBottom: appBarData.hasFilters,
      ),
    );
  }
}

/// Empty state view displayed when no network calls are available
class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No network calls",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

/// ListView that displays the filtered network calls
class _NetworkCallsListView extends StatelessWidget {
  const _NetworkCallsListView({
    required this.filteredCalls,
    required this.searchQuery,
  });

  final Set<InfospectNetworkCall> filteredCalls;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredCalls.length,
      itemBuilder: (context, index) {
        final call = filteredCalls.elementAt(index);
        return NetworkCallItem(
          networkCall: call,
          searchedText: searchQuery,
          onItemClicked: (call) => _navigateToDetails(context, call),
        );
      },
    );
  }

  void _navigateToDetails(BuildContext context, InfospectNetworkCall call) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => InterceptorDetailsBloc(),
          child: InterceptorDetailsScreen(call),
        ),
      ),
    );
  }
}
