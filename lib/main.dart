import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// ---------- Brown palette ----------
const kCream = Color(0xFFF4ECE1); // page background
const kCard = Color(0xFFFFFBF6); // card body
const kHeader = Color(0xFFEBDDC8); // header band
const kCoffee = Color(0xFF6F4E37); // buttons, accents
const kBorder = Color(0xFF5C4033); // all borders
const kMocha = Color(0xFF8A6246); // labels
const kLatte = Color(0xFFD9C7A8); // inactive dots
const kFieldFill = Color(0xFFF8F0E4); // text field background
const kInk = Color(0xFF3E2C23); // main text

const double kBorderWidth = 2;
const double kRadius = 12;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Student & Subject',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kCoffee),
          scaffoldBackgroundColor: kCream,
        ),
        home: const UserRegistrationPage(),
      );
}

// ---------- Shared widgets ----------
class Frame extends StatelessWidget {
  final String title;
  final int step; // 1, 2 or 3
  final List<Widget> children;
  final Widget button;
  const Frame({
    super.key,
    required this.title,
    required this.step,
    required this.children,
    required this.button,
  });

  Widget dots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final active = i + 1 == step;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? kCoffee : kLatte,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(kRadius + 8),
                    border: Border.all(color: kBorder, width: kBorderWidth),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kRadius + 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header band with bottom border
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                          decoration: const BoxDecoration(
                            color: kHeader,
                            border: Border(
                              bottom: BorderSide(color: kBorder, width: kBorderWidth),
                            ),
                          ),
                          child: Column(
                            children: [
                              dots(),
                              const SizedBox(height: 14),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                  color: kInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Body
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              ...children,
                              const SizedBox(height: 8),
                              button,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

Widget brownButton(String text, VoidCallback onPressed) => SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: kCoffee,
          foregroundColor: Colors.white,
          side: const BorderSide(color: kBorder, width: kBorderWidth),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
          textStyle: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        child: Text(text),
      ),
    );

OutlineInputBorder fieldBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadius),
      borderSide: BorderSide(color: color, width: kBorderWidth),
    );

// Label above a fully bordered box (blank by default)
Widget inputRow(String label, TextEditingController c, {bool autofocus = false}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kMocha,
              ),
            ),
          ),
          TextField(
            controller: c,
            autofocus: autofocus,
            cursorColor: kCoffee,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 17, color: kInk),
            decoration: InputDecoration(
              filled: true,
              fillColor: kFieldFill,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: fieldBorder(kBorder),
              enabledBorder: fieldBorder(kBorder),
              focusedBorder: fieldBorder(kCoffee),
            ),
          ),
        ],
      ),
    );

void showMsg(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kCoffee,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: const BorderSide(color: kBorder, width: kBorderWidth),
      ),
      content: Text(text, style: const TextStyle(color: Colors.white)),
    ),
  );
}

// ---------- Screen 1: User Registration ----------
class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({super.key});
  @override
  State<UserRegistrationPage> createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final name = TextEditingController();
  final section = TextEditingController();
  final course = TextEditingController();

  void goNext() {
    if (name.text.trim().isEmpty ||
        section.text.trim().isEmpty ||
        course.text.trim().isEmpty) {
      showMsg(context, 'Please fill in Name, Section, and Course');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectEnrollmentPage(
          name: name.text.trim(),
          section: section.text.trim(),
          course: course.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Frame(
        title: 'User Registration',
        step: 1,
        children: [
          inputRow('Name', name, autofocus: true),
          inputRow('Section', section),
          inputRow('Course', course),
        ],
        button: brownButton('Next', goNext),
      );
}

// ---------- Screen 2: Subject Enrollment ----------
class SubjectEnrollmentPage extends StatefulWidget {
  final String name, section, course;
  const SubjectEnrollmentPage(
      {super.key, required this.name, required this.section, required this.course});
  @override
  State<SubjectEnrollmentPage> createState() => _SubjectEnrollmentPageState();
}

class _SubjectEnrollmentPageState extends State<SubjectEnrollmentPage> {
  final subject1 = TextEditingController();
  final time1 = TextEditingController();
  final subject2 = TextEditingController();
  final time2 = TextEditingController();

  void goNext() {
    if (subject1.text.trim().isEmpty ||
        time1.text.trim().isEmpty ||
        subject2.text.trim().isEmpty ||
        time2.text.trim().isEmpty) {
      showMsg(context, 'Please fill in both subjects and their times');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectVerificationPage(
          name: widget.name,
          section: widget.section,
          course: widget.course,
          subject1: subject1.text.trim(),
          time1: time1.text.trim(),
          subject2: subject2.text.trim(),
          time2: time2.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Frame(
        title: 'Subject Enrollment',
        step: 2,
        children: [
          inputRow('Subject', subject1, autofocus: true),
          inputRow('time', time1),
          const SizedBox(height: 8),
          inputRow('Subject', subject2),
          inputRow('time', time2),
        ],
        button: brownButton('Next', goNext),
      );
}

// ---------- Screen 3: Subject Verification (editable) ----------
class SubjectVerificationPage extends StatefulWidget {
  final String name, section, course, subject1, time1, subject2, time2;
  const SubjectVerificationPage({
    super.key,
    required this.name,
    required this.section,
    required this.course,
    required this.subject1,
    required this.time1,
    required this.subject2,
    required this.time2,
  });
  @override
  State<SubjectVerificationPage> createState() => _SubjectVerificationPageState();
}

class _SubjectVerificationPageState extends State<SubjectVerificationPage> {
  late final nameC = TextEditingController(text: widget.name);
  late final sectionC = TextEditingController(text: widget.section);
  late final courseC = TextEditingController(text: widget.course);
  late final subject1C = TextEditingController(text: widget.subject1);
  late final time1C = TextEditingController(text: widget.time1);
  late final subject2C = TextEditingController(text: widget.subject2);
  late final time2C = TextEditingController(text: widget.time2);

  Future<void> save() async {
    try {
      await FirebaseFirestore.instance.collection('students').add({
        'name': nameC.text.trim(),
        'section': sectionC.text.trim(),
        'course': courseC.text.trim(),
        'subjects': [
          {'subject': subject1C.text.trim(), 'time': time1C.text.trim()},
          {'subject': subject2C.text.trim(), 'time': time2C.text.trim()},
        ],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      showMsg(context, 'Saved to Firebase!');
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      showMsg(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Frame(
        title: 'Subject Verification',
        step: 3,
        children: [
          inputRow('Name', nameC),
          inputRow('Section', sectionC),
          inputRow('Course', courseC),
          const SizedBox(height: 8),
          inputRow('①', subject1C),
          inputRow('time', time1C),
          inputRow('②', subject2C),
          inputRow('time', time2C),
        ],
        button: brownButton('Save', save),
      );
}