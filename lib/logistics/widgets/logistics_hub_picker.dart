import 'package:flutter/material.dart';

import '../../services/sari_live_data.dart';

class LogisticsHubPicker
    extends StatefulWidget {
  const LogisticsHubPicker({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<int?> onChanged;

  @override
  State<LogisticsHubPicker>
      createState() =>
          _LogisticsHubPickerState();
}

class _LogisticsHubPickerState
    extends State<LogisticsHubPicker> {
  List<Map<String, dynamic>>
      _branches =
      [];

  int? _selected;

  String? _error;

  bool _busy = true;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData
              .instance
              .logisticsBranches();

      final body =
          response['data'];

      final items =
          body is Map
              ? body['branches']
              : null;

      final branches =
          items is List
              ? items
                  .whereType<Map>()
                  .map(
                    (
                      e,
                    ) =>
                        Map<String,
                                dynamic>.from(
                          e,
                        ),
                  )
                  .toList()
              : <Map<String,
                  dynamic>>[];

      if (!mounted) {
        return;
      }

      setState(() {
        _branches =
            branches;

        _selected =
            branches.isEmpty
                ? null
                : (branches.first[
                            'id']
                        as num)
                    .toInt();
      });

      widget.onChanged(
        _selected,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            error.toString();

        _selected =
            null;
      });

      widget.onChanged(
        null,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy =
              false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_busy) {
      return const Padding(
        padding:
            EdgeInsets.all(
          10,
        ),
        child:
            LinearProgressIndicator(),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          Text(
            'Cannot load authorized hubs: $_error',
          ),
          TextButton(
            onPressed:
                _load,
            child:
                const Text(
              'Retry',
            ),
          ),
        ],
      );
    }

    if (_branches.isEmpty) {
      return const Text(
        'No active Logistics hub is assigned to this provider.',
      );
    }

    return DropdownButtonFormField<int>(
      initialValue:
          _selected,
      isExpanded:
          true,
      decoration:
          const InputDecoration(
        labelText:
            'Operating hub',
        prefixIcon:
            Icon(
          Icons
              .warehouse_outlined,
        ),
        border:
            OutlineInputBorder(),
      ),
      items:
          _branches.map(
        (
          e,
        ) =>
            DropdownMenuItem<int>(
          value:
              (e['id'] as num)
                  .toInt(),
          child:
              Text(
            '${e['name'] ?? 'Hub'} • ${e['municipality_name'] ?? ''}',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
          ),
        ),
      ).toList(),
      onChanged:
          (
            next,
          ) {
        setState(() {
          _selected =
              next;
        });

        widget.onChanged(
          next,
        );
      },
    );
  }
}