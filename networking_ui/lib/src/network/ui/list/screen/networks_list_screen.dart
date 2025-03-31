import '/src/network/infospect_network_call.dart';
import '/src/network/network_storage.dart';
import '/src/network/ui/details/bloc/interceptor_details_bloc.dart';
import '/src/network/ui/details/screen/interceptor_details_screen.dart';
import '/src/network/ui/filters/network_filters.dart';
import '/src/network/ui/list/components/network_call_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/network_call_app_bar.dart';
import 'dart:io';

class NetworksListScreen extends StatefulWidget {
  const NetworksListScreen({super.key, required this.storage});
  final NetworkStorage storage;

  @override
  State<NetworksListScreen> createState() => _NetworksListScreenState();
}

class _NetworksListScreenState extends State<NetworksListScreen> {
  late final NetworkFilters _networkFilters;

  @override
  void initState() {
    super.initState();
    _networkFilters = NetworkFilters(networkCallsGetter: () => widget.storage.networkCalls);
    widget.storage.networkCall.addListener(_onNetworkCallsChanged);
  }

  void _onNetworkCallsChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.storage.networkCall.removeListener(_onNetworkCallsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final bool hasFilters = _networkFilters.selectedMethods.isNotEmpty;
    
    return PreferredSize(
      preferredSize: hasFilters 
          ? Size.fromHeight(kToolbarHeight + 5 + (Platform.isMacOS ? 25 : 0))
          : Size.fromHeight(kToolbarHeight),
      child: ListenableBuilder(
        listenable: _networkFilters,
        builder: (context, _) {
          return NetworkCallAppBar(
            filters: _networkFilters,
            hasBottom: _networkFilters.selectedMethods.isNotEmpty,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return NetworkListBody(filters: _networkFilters);
  }
}

class NetworkListBody extends StatelessWidget {
  const NetworkListBody({
    super.key,
    required this.filters,
  });
  
  final NetworkFilters filters;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: filters,
      builder: (context, _) {
        final filteredCalls = filters.filteredCalls;
        
        if (filteredCalls.isEmpty) {
          return const Center(child: Text("No network calls"));
        }
        
        return ListView.builder(
          itemCount: filteredCalls.length,
          itemBuilder: (context, index) {
            final call = filteredCalls.elementAt(index);
            return NetworkCallItem(
              networkCall: call,
              searchedText: filters.query,
              onItemClicked: (call) => _navigateToDetails(context, call),
            );
          },
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
