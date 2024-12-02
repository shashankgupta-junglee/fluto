import 'package:fluto_core/fluto.dart';
import 'package:fluto_core/src/extension/fluto_log_extension.dart';
import 'package:fluto_core/src/logger/log_details_page.dart';
import 'package:fluto_core/src/logger/logger_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogViewer extends StatefulWidget {
  const LogViewer({super.key});

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  late FlutoLoggerProvider _flutoLoggerProvider;
  FlutoLogType _selectedLogType = FlutoLogType.debug;
  final TextEditingController _logSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((time) {
      setState(() {
        _flutoLoggerProvider =
            Provider.of<FlutoLoggerProvider>(context, listen: false);
        _flutoLoggerProvider.syncLocalLogs();
        _selectedLogType = FlutoLogType.values.first;
      });
    });
  }

  Future<void> showPicker() async {
    // Show Date Range Picker
    DateTimeRange? dateTimeRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(
        const Duration(days: 100),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 100),
      ),
      initialDateRange: _flutoLoggerProvider.dateTimeRange,
    );

    if (dateTimeRange != null) {
      // Show Time Picker for Start Time
      TimeOfDay? startTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: "Select Start Time",
      );

      if (startTime == null) return; // User canceled the start time picker

      // Show Time Picker for End Time
      TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: startTime,
        helpText: "Select End Time",
      );

      if (endTime == null) return; // User canceled the end time picker

      // Combine date range with start and end times
      DateTime startDateTime = DateTime(
        dateTimeRange.start.year,
        dateTimeRange.start.month,
        dateTimeRange.start.day,
        startTime.hour,
        startTime.minute,
      );

      DateTime endDateTime = DateTime(
        dateTimeRange.end.year,
        dateTimeRange.end.month,
        dateTimeRange.end.day,
        endTime.hour,
        endTime.minute,
      );

      // Notify the provider with the new date and time range
      _flutoLoggerProvider.onDateRangeChange(
        DateTimeRange(start: startDateTime, end: endDateTime),
        message: _logSearchController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
          child: TextField(
            onChanged: (value) {
              _flutoLoggerProvider.onSearchLogs(logMessage: value);
            },
            controller: _logSearchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    _logSearchController.clear();
                    _flutoLoggerProvider.clearSearch();
                  },
                  child: const Icon(
                    Icons.clear,
                    size: 25,
                  ),
                ),
              ),
              border: InputBorder.none,
              hintText: "Search ${_selectedLogType.name} logs",
            ),
          ),
        ),
        actions: [
          PopupMenuButton<FlutoLogType>(
            icon: const Icon(Icons.filter_list),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            onSelected: (FlutoLogType logType) {
              setState(() {
                _selectedLogType = logType;
              });
            },
            itemBuilder: (BuildContext context) {
              return FlutoLogType.values.map((logType) {
                return PopupMenuItem<FlutoLogType>(
                  value: logType,
                  child: Row(
                    children: [
                      Radio(
                        groupValue: _selectedLogType,
                        value: logType,
                        onChanged: (value) {
                          setState(() {
                            _selectedLogType = logType;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        logType.toString().split('.').last,
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Consumer<FlutoLoggerProvider>(
        builder: (context, logProvider, child) {
          final logs = logProvider.getAllLogs(
            logType: _selectedLogType,
          );
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () async {
                        showPicker();
                      },
                      child: Text(
                        logProvider.dateTimeRange != null
                            ? (logProvider.dateTimeRange.dateRangeString)
                            : "Select Date Range",
                        style: Theme.of(context).textTheme.titleMedium,
                      )),
                  if (logProvider.dateTimeRange != null)
                    IconButton(
                      onPressed: () {
                        _flutoLoggerProvider.clearDateRange(
                          logMessage: _logSearchController.text,
                        );
                      },
                      icon: const Icon(Icons.clear),
                    )
                  else
                    IconButton(
                      onPressed: () {
                        showPicker();
                      },
                      icon: const Icon(Icons.date_range),
                    )
                ],
              ),
              Expanded(
                child: LogsTab(
                  logs: logs,
                  logType: _selectedLogType,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // shape
        tooltip: "Clear ${_selectedLogType.name} logs",
        onPressed: () {
          _flutoLoggerProvider.clearLogs(type: _selectedLogType);
        },
        child: const Text(
          "Clear",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class LogsTab extends StatelessWidget {
  final List<FlutoLogModel> logs;
  final FlutoLogType logType;

  const LogsTab({
    super.key,
    required this.logs,
    required this.logType,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Text("No ${logType.name} logs found"),
      );
    }
    return ListView.builder(
      key: ValueKey(logs.length),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return log.canShow
            ? Dismissible(
                key: ValueKey(log.logTime),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      showLogDetailsDialog(
                        context: context,
                        flutoLog: log,
                      );
                    },
                    title: Text(
                      log.logMessage,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(log.getFormattedLogTime),
                    tileColor: Theme.of(context).focusColor,
                  ),
                ),
              )
            : const IgnorePointer();
      },
    );
  }
}
