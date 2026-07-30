import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/model/kokotoba_settings.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.rows});

  final String title;
  final List<SettingRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                InkWell(
                  onTap: () => showMessage(
                    context,
                    '${rows[i].label}: ${rows[i].value}',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            rows[i].label,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          rows[i].value,
                          style: const TextStyle(
                            color: rose700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text('  ›', style: TextStyle(color: mutedInk)),
                      ],
                    ),
                  ),
                ),
                if (i != rows.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ToggleGroup extends StatelessWidget {
  const ToggleGroup({
    super.key,
    required this.title,
    required this.labels,
    required this.values,
    required this.onChanged,
  });

  final String title;
  final List<String> labels;
  final Map<String, bool> values;
  final void Function(String, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          labels[i],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Switch(
                        value: values[labels[i]]!,
                        onChanged: (value) => onChanged(labels[i], value),
                      ),
                    ],
                  ),
                ),
                if (i != labels.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
