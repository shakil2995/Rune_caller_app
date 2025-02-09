import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/join_screen.dart';
import 'services/signalling.service.dart';

void main() {
  runApp(const VideoCallApp());
}

class VideoCallApp extends StatelessWidget {
  const VideoCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(),
      ),
      themeMode: ThemeMode.dark,
      home: const InitializationScreen(),
    );
  }
}

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  InitializationScreenState createState() => InitializationScreenState();
}

class InitializationScreenState extends State<InitializationScreen> {
  static const String callerIDKey = 'selfCallerID';
  String? selfCallerID;

  @override
  void initState() {
    super.initState();
    _initializeCallerID();
  }

Future<void> _initializeCallerID() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? storedCallerID = prefs.getString(callerIDKey);

    if (storedCallerID == null || storedCallerID.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PhoneNumberScreen(),
        ),
      );
    } else {
      setState(() {
        selfCallerID = storedCallerID;
      });
      _initializeSignallingService(storedCallerID);
    }
  } catch (e) {
    // Handle the error appropriately
    print('Error initializing caller ID: $e');
  }
}


  void _initializeSignallingService(String callerID) {
    SignallingService.instance.init(
      websocketUrl: "https://rune-caller-app.onrender.com/",
      selfCallerID: callerID,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selfCallerID == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return JoinScreen(selfCallerId: selfCallerID!);
  }
}

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  PhoneNumberScreenState createState() => PhoneNumberScreenState();
}

class PhoneNumberScreenState extends State<PhoneNumberScreen> {
  static const String callerIDKey = 'selfCallerID';
  final TextEditingController controller = TextEditingController();
  bool isValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Phone Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter your phone number to continue:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Phone Number",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 10.0),
              ),
              onChanged: (value) {
                setState(() {
                  isValid = value.length >= 11;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
  onPressed: isValid
      ? () async {
          try {
            final phoneNumber = controller.text;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(callerIDKey, phoneNumber);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const InitializationScreen(),
              ),
            );
          } catch (e) {
            // Handle the error appropriately
            print('Error saving phone number: $e');
          }
        }
      : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
