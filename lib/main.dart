import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Attendance Records',
      home: Introduction(),
    );
  }
}

void shareContact(String name, String phone) {
  final String text = "Contact name: $name\nPhone number: $phone";
  Share.share(text);
}

class Introduction extends StatelessWidget {
  const Introduction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<PageViewModel> pages = [
      PageViewModel(
        title: "Welcome to the Attendance Records app",
        body:
            "This app is designed to help you keep track of attendance records.",
        image: const Center(child: Icon(Icons.person)),
      ),
      PageViewModel(
        title: "Record Attendance",
        body: "Add a new attendance record by tapping the Add button.",
        image: const Center(child: Icon(Icons.add)),
      ),
      PageViewModel(
        title: "Search Records",
        body: "Find an attendance record by using the search feature.",
        image: const Center(child: Icon(Icons.search)),
      ),
    ];

    return IntroductionScreen(
      pages: pages,
      onDone: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const AttendanceList(),
          ),
        );
      },
      showSkipButton: true,
      skip: const Text("Skip"),
      done: const Text("Done"),
      showNextButton: false,
    );
  }
}

class AttendanceList extends StatefulWidget {
  const AttendanceList({Key? key}) : super(key: key);

  @override
  AttendanceListState createState() => AttendanceListState();
}

class AttendanceListState extends State<AttendanceList> {
  List<Map<String, dynamic>> attendanceRecords = [
    {
      "user": "Chan Saw Lin",
      "phone": "0152131113",
      "check-in": DateTime.parse("2020-06-30 16:10:05")
    },
    {
      "user": "Lee Saw Loy",
      "phone": "0161231346",
      "check-in": DateTime.parse("2020-07-11 15:39:59")
    },
    {
      "user": "Khaw Tong Lin",
      "phone": "0158398109",
      "check-in": DateTime.parse("2020-08-19 11:10:18")
    },
    {
      "user": "Lim Kok Lin",
      "phone": "0168279101",
      "check-in": DateTime.parse("2020-08-19 11:11:35")
    },
    {
      "user": "Low Jun Wei",
      "phone": "0112731912",
      "check-in": DateTime.parse("2020-08-15 13:00:05")
    },
    {
      "user": "Yong Weng Kai",
      "phone": "0172332743",
      "check-in": DateTime.parse("2020-07-31 18:10:11")
    },
    {
      "user": "Jayden Lee",
      "phone": "0191236439",
      "check-in": DateTime.parse("2020-08-22 08:10:38")
    },
    {
      "user": "Kong Kah Yan",
      "phone": "0111931233",
      "check-in": DateTime.parse("2020-07-11 12:00:00")
    },
    {
      "user": "Jasmine Lau",
      "phone": "0162879190",
      "check-in": DateTime.parse("2020-08-01 12:10:05")
    },
    {
      "user": "Chan Saw Lin",
      "phone": "016783239",
      "check-in": DateTime.parse("2020-08-23 11:59:05")
    }
  ];

  late ScaffoldMessengerState _scaffoldMessengerState;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> filteredRecords = [];
  bool isTimeAgoFormat = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPreferences();
    _scrollController.addListener(_scrollListener);
  }

  void getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTimeAgoFormat = prefs.getBool("isTimeAgoFormat") ?? true;
    });
  }

  void savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isTimeAgoFormat", isTimeAgoFormat);
  }

  void filterRecords(String query) {
    setState(() {
      filteredRecords = attendanceRecords.where((record) {
        return record["user"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _scaffoldMessengerState.showSnackBar(
        const SnackBar(
          content: Text('You have reached the end of the list.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    attendanceRecords.sort((a, b) => b['check-in'].compareTo(a['check-in']));
    _scaffoldMessengerState = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Records"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: AttendanceSearch(
                      records: attendanceRecords,
                      isTimeAgoFormat: isTimeAgoFormat));
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () {
              setState(() {
                isTimeAgoFormat = !isTimeAgoFormat;
                savePreferences();
              });
            },
          )
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: filteredRecords.isNotEmpty
            ? filteredRecords.length
            : attendanceRecords.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> record = filteredRecords.isNotEmpty
              ? filteredRecords[index]
              : attendanceRecords[index];
          return GestureDetector(
              onLongPress: () {
                shareContact(record['user'], record['phone']);
              },
              child: ListTile(
                title: Text(record["user"]),
                subtitle: Text(record["phone"]),
                trailing: Text(record["check-in"] != null
                    ? (isTimeAgoFormat
                        ? timeAgo(record["check-in"])
                        : DateFormat("dd/MM/yyyy hh:mm a")
                            .format(record["check-in"]))
                    : 'Not checked in'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AttendanceDetailsPage(record: record),
                    ),
                  );
                },
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAttendanceRecordScreen(),
            ),
          );

          if (result != null) {
            setState(() {
              attendanceRecords.add(result);
            });

            _scaffoldMessengerState.showSnackBar(
              const SnackBar(
                content: Text('New record added successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  static String timeAgo(DateTime date) {
    Duration difference = DateTime.now().difference(date);
    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return "$years year${years > 1 ? "s" : ""} ago";
    } else if (difference.inDays > 30) {
      int months = (difference.inDays / 30).floor();
      return "$months month${months > 1 ? "s" : ""} ago";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? "s" : ""} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? "s" : ""} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""} ago";
    } else if (difference.inSeconds > 0) {
      return "${difference.inSeconds} second${difference.inSeconds > 1 ? "s" : ""} ago";
    } else {
      return "Just now";
    }
  }
}

class AttendanceSearch extends SearchDelegate<String> {
  final List<Map<String, dynamic>> records;
  bool isTimeAgoFormat;

  AttendanceSearch({required this.records, required this.isTimeAgoFormat});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, dynamic>> results = records.where((record) {
      return record["user"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> record = results[index];
        return ListTile(
          title: Text(record["user"]),
          subtitle: Text(record["phone"]),
          trailing: Text(record["check-in"] != null
              ? (isTimeAgoFormat
                  ? AttendanceListState.timeAgo(record["check-in"])
                  : DateFormat("dd/MM/yyyy hh:mm a").format(record["check-in"]))
              : 'Not checked in'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceDetailsPage(record: record),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, dynamic>> suggestions = records.where((record) {
      return record["user"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> record = suggestions[index];
        return ListTile(
          title: Text(record["user"]),
          subtitle: Text(record["phone"]),
          trailing: Text(record["check-in"] != null
              ? (isTimeAgoFormat
                  ? AttendanceListState.timeAgo(record["check-in"])
                  : DateFormat("dd/MM/yyyy hh:mm a").format(record["check-in"]))
              : 'Not checked in'),
          onTap: () {
            query = record["user"];
            showResults(context);
          },
        );
      },
    );
  }
}

class AddAttendanceRecordScreen extends StatefulWidget {
  const AddAttendanceRecordScreen({Key? key}) : super(key: key);

  @override
  AddAttendanceRecordScreenState createState() =>
      AddAttendanceRecordScreenState();
}

class AddAttendanceRecordScreenState extends State<AddAttendanceRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _checkIn;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> newRecord = {
        "user": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "check-in": _checkIn ?? DateTime.now(),
      };
      Navigator.pop(context, newRecord);
    }
  }

  Future<TimeOfDay?> _selectTime() async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  void _showDateTimePicker() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now());
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await _selectTime();
      if (pickedTime != null) {
        setState(() {
          _checkIn = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Attendance Record"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Phone is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showDateTimePicker,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Check-in time",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (_checkIn == null) {
                        return "Check-in time is required";
                      }
                      return null;
                    },
                    controller: TextEditingController(
                      text: _checkIn == null
                          ? ""
                          : DateFormat("dd/MM/yyyy hh:mm a").format(_checkIn!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> record;

  const AttendanceDetailsPage({Key? key, required this.record})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Record Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              shareContact(record['user'], record['phone']);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record["user"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Phone: ${record["phone"]}",
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Check-in: ${record["check-in"] != null ? DateFormat("dd/MM/yyyy hh:mm a").format(record["check-in"]) : "Not checked in"}",
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
