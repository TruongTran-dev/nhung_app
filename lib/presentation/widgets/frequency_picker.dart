import 'package:flutter/material.dart';
import 'package:expensive_management/data/models/frequency_model.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/utils.dart';

class FrequencyPickerScreen extends StatefulWidget {
  final Frequency? frequency;
  final List<DayOfWeek>? listDay;

  const FrequencyPickerScreen({super.key, this.frequency, this.listDay});

  @override
  State<FrequencyPickerScreen> createState() => _FrequencyPickerScreenState();
}

class _FrequencyPickerScreenState extends State<FrequencyPickerScreen> {
  List<DayOfWeek> listDay = [];
  String? sortedTitles;

  Frequency frequencySelected = Frequency(
    title: 'Hàng ngày',
    frequencyType: FrequencyType.daily,
  );

  void initWhenEdit() {
    setState(() {
      frequencySelected = widget.frequency ??
          Frequency(
            title: 'Hàng ngày',
            frequencyType: FrequencyType.daily,
          );
      listDay = widget.listDay ?? [];
      sortedTitles = getListDayName(listDay);
    });
  }

  @override
  void initState() {
    initWhenEdit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () {
            if (frequencySelected.frequencyType == FrequencyType.weekday) {
              Navigator.of(context).pop(listDay);
            } else {
              Navigator.of(context).pop(frequencySelected);
            }
          },
          icon: const Icon(
            Icons.done,
            size: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Chọn tần suất lặp',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: listFrequency.length,
        itemBuilder: (context, index) {
          final frequency = listFrequency[index];

          return Container(
            decoration: BoxDecoration(
              border: BorderDirectional(
                top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2)),
                bottom: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            child: ListTile(
              title: Text(frequency.title),
              subtitle: (frequency.frequencyType == FrequencyType.weekday)
                  ? isNotNullOrEmpty(sortedTitles)
                      ? Text(
                          sortedTitles!,
                          textAlign: TextAlign.end,
                        )
                      : null
                  : null,
              trailing: frequencySelected.frequencyType == frequency.frequencyType
                  ? Icon(
                      Icons.check,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () async {
                setState(() {
                  frequencySelected = frequency;
                });

                if (frequency.frequencyType == FrequencyType.weekday) {
                  final List<DayOfWeek>? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DayOfWeekPickerScreen(listDay: listDay),
                    ),
                  );
                  setState(() {
                    listDay = result ?? [];
                    sortedTitles = getListDayName(listDay);
                  });
                } else {
                  // Handle other frequency types
                  // ...
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class DayOfWeekPickerScreen extends StatefulWidget {
  final List<DayOfWeek>? listDay;
  const DayOfWeekPickerScreen({super.key, this.listDay});

  @override
  DayOfWeekPickerScreenState createState() => DayOfWeekPickerScreenState();
}

class DayOfWeekPickerScreenState extends State<DayOfWeekPickerScreen> {
  List<DayOfWeek> selectedDays = [];

  bool isDaySelected(DayOfWeek day) {
    return selectedDays.contains(day);
  }

  void toggleDaySelection(DayOfWeek day) {
    setState(() {
      if (isDaySelected(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  void initListDay() {
    widget.listDay?.forEach((element) {
      selectedDays.add(element);
    });
  }

  @override
  void initState() {
    initListDay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(selectedDays);
            },
            icon: const Icon(
              Icons.done,
              size: 24,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          title: const Text(
            'Chọn ngày trong tuần',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: listDayOfWeek.length,
            itemBuilder: (context, index) {
              final day = listDayOfWeek[index];
              return ListTile(
                title: Text(day.title),
                trailing: isDaySelected(day) ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
                onTap: () {
                  toggleDaySelection(day);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
