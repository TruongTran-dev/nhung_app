import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as date_time_picker;

void showDatePickerPlus(
  BuildContext context, {
  bool isTimePicker = false,
  DateTime? minTime,
  DateTime? maxTime,
  DateTime? currentTime,
  Function(DateTime)? onConfirm,
  Function(DateTime)? onChanged,
  Function()? onCancel,
  Function()? whenComplete,
}) async =>
    date_time_picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: minTime,
      maxTime: maxTime,
      locale: date_time_picker.LocaleType.vi,
      currentTime: currentTime,
      onConfirm: onConfirm,
      onChanged: onChanged,
      onCancel: onCancel,
    ).whenComplete(() => whenComplete);

void showTimePickerPlus(
  BuildContext context, {
  DateTime? currentTime,
  Function(DateTime)? onConfirm,
  Function(DateTime)? onChanged,
  Function()? onCancel,
  Function()? whenComplete,
}) =>
    date_time_picker.DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      locale: date_time_picker.LocaleType.vi,
      currentTime: currentTime,
      onConfirm: onConfirm,
      onChanged: onChanged,
      onCancel: onCancel,
    ).whenComplete(() => whenComplete);
