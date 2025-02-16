import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/data/models/frequency_model.dart';
import 'package:expensive_management/data/models/recurring_post_model.dart';
import 'package:expensive_management/presentation/widgets/frequency_picker.dart';
import 'package:expensive_management/utils/enum/date_time_picker.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/utils.dart';

class OptionRepeatTime extends StatefulWidget {
  final String? fromDate, toDate, time;
  final FrequencyType frequencyType;
  final List<DayOfWeek>? listDay;

  const OptionRepeatTime({
    Key? key,
    this.fromDate,
    this.toDate,
    this.time,
    this.frequencyType = FrequencyType.daily,
    this.listDay,
  }) : super(key: key);

  @override
  State<OptionRepeatTime> createState() => _OptionRepeatTimeState();
}

class _OptionRepeatTimeState extends State<OptionRepeatTime> {
  String dateStart = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? dateEnd;
  String time = DateFormat('HH:mm:ss').format(DateTime.now());
  Frequency frequency = Frequency(title: 'Hàng ngày', frequencyType: FrequencyType.daily);
  List<DayOfWeek> listDay = [];
  String? nameDayOfWeek;

  void initWhenEdit() {
    setState(() {
      dateStart = widget.fromDate ?? '';
      dateEnd = widget.toDate;
      time = widget.time ?? '';
      frequency = getFrequencyByType(widget.frequencyType);
      listDay = widget.listDay ?? [];
      nameDayOfWeek = getListDayName(listDay);
    });
  }

  @override
  void initState() {
    initWhenEdit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('Tùy chọn lặp lại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
          actions: [
            IconButton(
              onPressed: () {
                if (isNullOrEmpty(time)) {
                  showMessage1OptionDialog(context, 'Vui lòng chọn thời gian');
                } else {
                  OptionRepeatData optionRepeatData = OptionRepeatData(dayOfWeeks: listDay, frequency: frequency, fromDate: dateStart, toDate: dateEnd ?? '', time: time);
                  Navigator.of(context).pop(optionRepeatData);
                }
              },
              icon: const Icon(Icons.done, size: 24, color: Colors.white),
            ),
          ],
        ),
        body: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectDateStart(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectDateEnd(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectTime(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectFrequency(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _selectDateStart() {
    return ListTile(
      onTap: () => showDatePickerPlus(
        context,
        minTime: DateTime(2000, 01, 01),
        maxTime: DateTime(2025, 12, 30),
        currentTime: DateTime.now(),
        onConfirm: (date) {
          setState(() {
            dateStart = DateFormat('yyyy-MM-dd').format(date);
          });
        },
        onCancel: () {
          setState(() {});
        },
      ),
      dense: false,
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
      leading: const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ngày bắt đầu', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
          Text(dateStart, style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _selectDateEnd() {
    return ListTile(
      onTap: () => showDatePickerPlus(
        context,
        minTime: DateTime(2000, 01, 01),
        maxTime: DateTime(2025, 12, 30),
        currentTime: DateTime.now(),
        onConfirm: (date) {
          setState(() {
            dateEnd = DateFormat('yyyy-MM-dd').format(date);
          });
        },
        onCancel: () {
          setState(() {});
        },
      ),
      dense: false,
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
      leading: const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ngày kêt thúc', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
          Text(isNotNullOrEmpty(dateEnd) ? dateEnd! : 'Không xác định', style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _selectTime() {
    return ListTile(
      onTap: () => showDatePickerPlus(
        context,
        currentTime: DateTime.now(),
        onConfirm: (date) {
          setState(() {
            time = DateFormat('HH:mm:ss').format(date);
          });
        },
        onCancel: () {
          setState(() {});
        },
      ),
      dense: false,
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
      leading: const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Thời gian', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
          Text(isNotNullOrEmpty(time) ? time : 'Không xác định', style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _selectFrequency() {
    return ListTile(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => FrequencyPickerScreen(frequency: frequency, listDay: listDay)));
        if (result is Frequency) {
          setState(() {
            frequency = result;
          });
        } else if (result is List<DayOfWeek>) {
          result.sort((a, b) => a.index.compareTo(b.index));
          List<String> titles = result.map((day) => day.title).toList();

          setState(() {
            frequency = Frequency(title: 'Ngày trong tuần', frequencyType: FrequencyType.weekday);
            listDay = result;
            nameDayOfWeek = titles.join(', ');
          });
        } else {
          return;
        }
      },
      dense: false,
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
      leading: const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tần suất',
            style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4)),
          ),
          Text(
            (frequency.frequencyType == FrequencyType.weekday ? nameDayOfWeek : frequency.title) ?? 'Hằng ngày',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}
