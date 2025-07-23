import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RulesTable extends StatelessWidget {
  const RulesTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildComparisonTable(),
    );
  }
}

Widget _buildComparisonTable() {
  return Table(
    border: TableBorder(
      horizontalInside: BorderSide(
        color: Colors.grey.shade300,
        style: BorderStyle.solid,
        width: 1.0,
      ),
    ),
    children: [
      TableRow(
        children: [
          _buildTableCell('rules_table.rule'.tr(), bold: true),
          _buildTableCell('rules_table.3x3'.tr(), bold: true),
          _buildTableCell('rules_table.basketball'.tr(), bold: true),
        ],
      ),
      _buildDataRow(
        'rules_table.hoop'.tr(),
        'rules_table.hoop_3x3'.tr(),
        'rules_table.hoop_basketball'.tr(),
      ),
      _buildDataRow(
        'rules_table.court'.tr(),
        'rules_table.court_3x3'.tr(),
        'rules_table.court_basketball'.tr(),
      ),
      _buildDataRow(
        'rules_table.players'.tr(),
        'rules_table.players_3x3'.tr(),
        'rules_table.players_basketball'.tr(),
      ),
      _buildDataRow(
        'rules_table.ball'.tr(),
        'rules_table.ball_3x3'.tr(),
        'rules_table.ball_basketball'.tr(),
      ),
      _buildDataRow(
        'rules_table.playing_time'.tr(),
        'rules_table.playing_time_3x3'.tr(),
        'rules_table.playing_time_basketball'.tr(),
      ),
      _buildDataRow(
        'rules_table.game_over'.tr(),
        'rules_table.game_over_3x3'.tr(),
        'rules_table.game_over_basketball'.tr(),
      ),
      _buildDataRow(
        'rules_table.shot_clock'.tr(),
        'rules_table.shot_clock_3x3'.tr(),
        'rules_table.shot_clock_basketball'.tr(),
      ),
      _buildDataRow(
        'rules_table.field_goals'.tr(),
        'rules_table.field_goals_3x3'.tr(),
        'rules_table.field_goals_basketball'.tr(),
      ),
      _buildDataRow(
        'rules_table.after_scoring'.tr(),
        'rules_table.after_scoring_3x3'.tr(),
        'rules_table.after_scoring_basketball'.tr(),
      ),
    ],
  );
}

Widget _buildTableCell(String text, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: 16,
      ),
    ),
  );
}

TableRow _buildDataRow(String rule, String threeXThree, String basketball) {
  return TableRow(
    children: [
      _buildTableCell(rule),
      _buildTableCell(threeXThree),
      _buildTableCell(basketball),
    ],
  );
}
