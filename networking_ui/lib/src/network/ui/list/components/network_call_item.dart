import 'package:flutter/material.dart';
import 'package:networking_ui/src/extensions/datetime_extension.dart';
import 'package:networking_ui/src/extensions/int_extension.dart';

import '../../common_widgets/conditional_widget.dart';
import '../../common_widgets/highlight_text_widget.dart';
import '/src/network/infospect_network_call.dart';

/// Widget that displays a network call item in a list view.
class NetworkCallItem extends StatelessWidget {
final InfospectNetworkCall networkCall;
  final Function(InfospectNetworkCall) onItemClicked;
  final String searchedText;

  const NetworkCallItem({
    super.key,
    required this.networkCall,
    required this.onItemClicked,
    this.searchedText = '',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onItemClicked(networkCall),
      enableFeedback: true,
      child: _ItemContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            _HeaderInfoRow(networkCall: networkCall),
            const SizedBox(height: 4),
            _RequestUrlDisplay(
              url: networkCall.request?.url?.toString() ?? '',
              searchedText: searchedText,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

/// Container widget for the network call item
class _ItemContainer extends StatelessWidget {
  final Widget child;

  const _ItemContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
        child: child,
      ),
    );
  }
}

/// Displays the request URL with highlighting for search text
class _RequestUrlDisplay extends StatelessWidget {
  final String url;
  final String searchedText;

  const _RequestUrlDisplay({
    required this.url,
    required this.searchedText,
  });

  @override
  Widget build(BuildContext context) {
    return HighlightText(
      text: url,
      highlight: searchedText,
      selectable: false,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

/// Row displaying header information about the network call
class _HeaderInfoRow extends StatelessWidget {
  final InfospectNetworkCall networkCall;

  const _HeaderInfoRow({required this.networkCall});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        // Status indicator
        _StatusIndicatorWidget(networkCall: networkCall),

        // Method
        Text(
          networkCall.request?.method.toString() ?? '', 
          style: textTheme.labelMedium
        ),

        // Response status
        _ResponseStatusWidget(networkCall),

        // Time
        _InfoLabel(
          ' • ${(networkCall.request?.time ?? DateTime.now()).formatTime}',
          textTheme: textTheme,
        ),

        // Duration
        _InfoLabel(
          ' • ${networkCall.duration.toReadableTime}',
          textTheme: textTheme,
        ),

        // Transferred bytes
        _InfoLabel(
          " • ${(networkCall.request?.size ?? 0).toReadableBytes} ↑ / "
          "${(networkCall.response?.size ?? 0).toReadableBytes} ↓",
          textTheme: textTheme,
        ),
      ],
    );
  }
}

/// Reusable widget for info labels
class _InfoLabel extends StatelessWidget {
  final String text;
  final TextTheme textTheme;

  const _InfoLabel(this.text, {required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: textTheme.labelSmall);
  }
}

/// Status indicator showing loading state or status color
class _StatusIndicatorWidget extends StatelessWidget {
  final InfospectNetworkCall networkCall;
  
  const _StatusIndicatorWidget({required this.networkCall});

  @override
  Widget build(BuildContext context) {
    return ConditionalWidget(
      condition: networkCall.loading,
      ifTrue: SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.error,
          strokeWidth: 1,
        ),
      ),
      ifFalse: Container(
        height: 10,
        width: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getStatusColor(networkCall.response, context),
        ),
      ),
    );
  }

  Color? _getStatusColor(InfospectNetworkResponse? response, BuildContext context) {
    final status = response?.status ?? -1;
    
    if (status == -1) {
      return Colors.red[400];
    } else if (status < 200) {
      return Theme.of(context).textTheme.bodyLarge!.color;
    } else if (status >= 200 && status < 300) {
      return Colors.green[400];
    } else if (status >= 300 && status < 400) {
      return Colors.orange[400];
    } else if (status >= 400 && status < 600) {
      return Colors.red[400];
    } else {
      return Theme.of(context).textTheme.bodyLarge!.color;
    }
  }
}

/// Widget that shows the response status text
class _ResponseStatusWidget extends StatelessWidget {
  final InfospectNetworkCall networkCall;
  
  const _ResponseStatusWidget(this.networkCall);

  String _formatStatusCode(int status) {
    if (status == -1) {
      return "ERR";
    } else if (status < 200) {
      return status.toString();
    } else if (status >= 200 && status < 300) {
      return "$status OK";
    } else if (status >= 300 && status < 400) {
      return status.toString();
    } else if (status >= 400 && status < 600) {
      return status.toString();
    } else {
      return "ERR";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConditionalWidget(
      condition: networkCall.loading,
      ifTrue: const SizedBox.shrink(),
      ifFalse: Text(
        ' • ${_formatStatusCode(networkCall.response?.status ?? -1)}',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
