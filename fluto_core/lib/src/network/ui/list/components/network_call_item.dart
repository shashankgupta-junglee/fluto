import 'package:fluto_core/src/extension/datetime_extension.dart';
import 'package:fluto_core/src/extension/int_extension.dart';
import 'package:fluto_core/src/network/infospect_network_call.dart';
import 'package:fluto_core/src/utils/common_widgets/highlight_text_widget.dart';
import 'package:flutter/material.dart';

import '../../../../utils/common_widgets/conditional_widget.dart';

class NetworkCallItem extends StatelessWidget {
  final InfospectNetworkCall networkCall;
  final Function onItemClicked;
  final String searchedText;

  const NetworkCallItem({
    super.key,
    required this.networkCall,
    required this.onItemClicked,
    this.searchedText = '',
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => onItemClicked(networkCall),
      enableFeedback: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  /// Loader or status indicator
                  _StatusIndicatorWidget(networkCall: networkCall),

                  /// Method
                  Text(networkCall.request?.method.toString() ?? '', style: textTheme.labelMedium),

                  /// Status
                  _ResponseStatusWidget(networkCall),

                  /// Time
                  Text(
                    ' • ${(networkCall.request?.time ?? DateTime.now()).formatTime}',
                    style: textTheme.labelSmall,
                  ),

                  /// Duration
                  Text(
                    ' • ${networkCall.duration.toReadableTime}',
                    style: textTheme.labelSmall,
                  ),

                  /// Transfered bytes
                  Text(
                    " • ${(networkCall.request?.size ?? 0).toReadableBytes} ↑ / "
                    "${(networkCall.response?.size ?? 0).toReadableBytes} ↓",
                    style: textTheme.labelSmall,
                  )
                ],
              ),
              const SizedBox(height: 4),

              /// Path
              HighlightText(
                text: networkCall.request == null ? '' : networkCall.request!.url.toString(),
                highlight: searchedText,
                selectable: false,
                style: textTheme.titleMedium,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicatorWidget extends StatelessWidget {
  const _StatusIndicatorWidget({
    required this.networkCall,
  });

  final InfospectNetworkCall networkCall;

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
          color: getStatusTextColor(networkCall.response, context),
        ),
      ),
    );
  }

  Color? getStatusTextColor(InfospectNetworkResponse? response, BuildContext context) {
    int status = response?.status ?? -1;
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

class _ResponseStatusWidget extends StatelessWidget {
  final InfospectNetworkCall networkCall;
  const _ResponseStatusWidget(this.networkCall);

  String statusString(int status) {
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
        // ' • ${networkCall.response?.statusString ?? ''}',
        ' • ${statusString(networkCall.response?.status ?? -1)}',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
