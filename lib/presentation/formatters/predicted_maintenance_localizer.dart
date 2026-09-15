import 'package:flutter/widgets.dart';

import 'package:petvita/core/utils/calendar_day.dart';
import 'package:petvita/data/models/predicted_maintenance.dart';
import 'package:petvita/i18n/generated/app_localizations.dart';

extension PredictedMaintenanceLocalizer on PredictedMaintenanceInfo {
  String displayInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final daysRemaining = CalendarDay.daysUntil(predictedDueDate);
    final dueLabel = daysRemaining >= 0
        ? l10n.daysLater(daysRemaining)
        : l10n.daysOverdue(-daysRemaining);
    return l10n.nextMaintenanceSummary(planItem.itemName, dueLabel);
  }
}
