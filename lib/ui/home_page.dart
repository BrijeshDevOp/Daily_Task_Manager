// home_page.dart
// ignore_for_file: avoid_unnecessary_containers, unused_field
import 'package:intl/intl.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:dtm1/controllers/task_controller.dart';
import 'package:dtm1/models/task.dart';
import 'package:dtm1/ui/add_task_page.dart';
import 'package:dtm1/ui/themes.dart';
import 'package:dtm1/ui/widgets/buttons.dart';
import 'package:dtm1/ui/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:dtm1/services/notification_services.dart';
import 'package:dtm1/services/theme_services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  late NotificationService notificationService;
  final _taskController = Get.put(TaskController());

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    notificationService = NotificationService();
    NotificationService.initialize();
    _taskController.getTasks(); // Add this line
  }

  @override
  Widget build(BuildContext context) {
    final themeServices = Get.find<ThemeServices>();

    return Scaffold(
      appBar: _addAppBar(themeServices),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(
            height: 10,
          ),
          _showTasks(),
        ],
      ),
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        if (_taskController.taskList.isEmpty) {
          return Center(
            child: Text(
              "No tasks available.",
              style: subTitleStyle,
            ),
          );
        } else {
          return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              Task task = _taskController.taskList[index];

              try {
                if (task.repeat == 'Daily') {
                  String? originalStartTime = task.startTime;
                  // print("Original startTime: '$originalStartTime'");

                  // Clean startTime
                  String cleanTime = originalStartTime!
                      .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
                      .trim();
                  // print("Cleaned startTime: '$cleanTime'");

                  // Manual parsing
                  var timeParts = cleanTime.split(' ');
                  if (timeParts.length == 2) {
                    var timeString = timeParts[0]; // '11:38'
                    var amPm = timeParts[1]; // 'AM'
                    var splitTime = timeString.split(':');
                    if (splitTime.length == 2) {
                      int hour = int.parse(splitTime[0]);
                      int minute = int.parse(splitTime[1]);
                      if (amPm == 'PM' && hour != 12) {
                        hour += 12;
                      } else if (amPm == 'AM' && hour == 12) {
                        hour = 0;
                      }

                      // Set notification time for the current date with parsed time
                      DateTime notificationTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        hour,
                        minute,
                      );

                      // Ensure the notification is scheduled only if the time is in the future
                      if (notificationTime.isAfter(DateTime.now())) {
                        NotificationService.scheduleNotification(
                          title: task.title ?? "Task Reminder",
                          body: task.note ?? "It's time for your task!",
                          scheduledDate: notificationTime,
                        );
                        // print("Scheduled Notification at: $notificationTime");
                      } else {
                        // print("Notification time is in the past, skipping.");
                      }

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        child: SlideAnimation(
                          child: FadeInAnimation(
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showBottomSheet(context, task);
                                  },
                                  child: TaskTile(task),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  throw const FormatException("Invalid time format");
                }

                if (task.date == DateFormat.yMd().format(_selectedDate)) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              } catch (e) {
                // print("Error parsing time: $e");
                return Container(); // Handle gracefully
              }

              return Container();
            },
          );
        }
      }),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.only(top: 4),
      height: task.isCompleted == 1
          ? MediaQuery.of(context).size.height * 0.24
          : MediaQuery.of(context).size.height * 0.32,
      color: Get.isDarkMode ? darkGreyClr : Colors.white,
      child: Column(
        children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          ),
          const Spacer(),
          task.isCompleted == 1
              ? Container()
              : _bottomSheetButton(
                  label: "Task Completed",
                  onTap: () {
                    _taskController.markTaskCompleted(task.id!);
                    Get.back();
                  },
                  clr: const Color.fromARGB(255, 159, 250, 191),
                  txtColor: Colors.green,
                  context: context,
                ),
          _bottomSheetButton(
            label: "Delete Task",
            onTap: () {
              _taskController.delete(task);
              Get.back();
            },
            clr: Colors.red[200]!,
            txtColor: Colors.red,
            context: context,
          ),
          const SizedBox(
            height: 20,
          ),
          _bottomSheetButton(
            label: "Close",
            onTap: () {
              Get.back();
            },
            clr: Colors.red[300]!,
            txtColor: Colors.grey,
            isClose: true,
            context: context,
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    ));
  }

  _bottomSheetButton(
      {required String label,
      required Function()? onTap,
      required Color clr,
      required Color txtColor,
      bool isClose = false,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: isClose == true ? Colors.transparent : clr,
          border: Border.all(
              width: 2,
              color: isClose == true
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : clr),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            label,
            style: isClose ? titleStyle : titleStyle.copyWith(color: txtColor),
          ),
        ),
      ),
    );
  }

  _addDateBar() {
    final now = DateTime.now(); // Store DateTime.now() to reuse

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        now,
        height: 100,
        width: 80,
        initialSelectedDate: now,
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: titleStyle.copyWith(fontSize: 20),
        dayTextStyle: titleStyle.copyWith(fontSize: 16),
        monthTextStyle: subTitleStyle.copyWith(fontSize: 14),
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                const Text(
                  "Today",
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                ),
              ],
            ),
          ),
          MyButton(
              label: "+ Add Task ",
              onTap: () async {
                await Get.to(const AddTaskPage());
                _taskController.getTasks();
              })
        ],
      ),
    );
  }

  _addAppBar(themeServices) {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          themeServices.switchTheme();
          // NotificationService.showInstantNotification(
          //   title: "Theme Changed",
          //   body: themeServices.isDarkMode.value
          //       ? "Activated Light Mode"
          //       : "Activated Dark Mode",
          // );
        },
        child: Obx(() {
          return Icon(
            themeServices.isDarkMode.value
                ? Icons.sunny
                : Icons.nightlight_sharp,
            size: 20,
            color: themeServices.isDarkMode.value ? Colors.white : Colors.black,
          );
        }),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right:12.0),
          child: Text(
            "D.T.M",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily:'Roboto'
            ),
          ),
        )
      ],
    );
  }
}
