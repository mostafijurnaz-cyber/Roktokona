import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ================= গুগল শিট সার্ভিস =================
class GoogleSheetService {
  static const String _url = 'https://script.google.com/macros/s/AKfycby4sZPx79LJvvX6DEi3KvI91jm-dTmJ8K_EhQ1RLOgRgWmAmjGPX4ij-Ya3IdSH-lx0TA/exec';

  static Future<bool> addDonor({
    required String name,
    required String phone,
    required String email,
    required String bloodGroup,
    required String gender,
    required String address,
    required String lastDonationDate,
    required String password,
    required String totalDonations,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: jsonEncode({
          "action": "addDonor",
          "name": name,
          "phone": phone,
          "email": email,
          "bloodGroup": bloodGroup,
          "gender": gender,
          "address": address,
          "lastDonationDate": lastDonationDate,
          "password": password,
          "totalDonations": totalDonations,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> addBloodRequest({
    required String patientName,
    required String bloodGroup,
    required String problem,
    required String location,
    required String bags,
    required String neededDate,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: jsonEncode({
          "action": "addRequest",
          "patientName": patientName,
          "bloodGroup": bloodGroup,
          "problem": problem,
          "location": location,
          "bags": bags,
          "neededDate": neededDate,
          "phone": phone,
          "timestamp": DateTime.now().toString(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> addFeedback({
    required String name,
    required String phone,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: jsonEncode({
          "action": "addFeedback",
          "name": name,
          "phone": phone,
          "message": message,
          "timestamp": DateTime.now().toString(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// গ্লোবাল স্টেট বা ইউজার ইনফো সংরক্ষণের জন্য
class UserSession {
  static bool isLoggedIn = false;
  static Map<String, dynamic> donorData = {};

  static Future<void> saveLogin(Map<String, dynamic> data) async {
    isLoggedIn = true;
    donorData = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('donorData', jsonEncode(data));
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? dataStr = prefs.getString('donorData');
    if (dataStr != null) {
      donorData = jsonDecode(dataStr);
    }
  }

  static Future<void> logout() async {
    isLoggedIn = false;
    donorData = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.loadSession();
  runApp(const RoktokonaApp());
}

class RoktokonaApp extends StatelessWidget {
  const RoktokonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'রক্তকণা যুব সামাজিক সংগঠন - পিরোজপুর',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const MainTabScreen(),
    );
  }
}

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/logo.png',
                height: 38,
                width: 38,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.bloodtype, size: 36, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'রক্তকণা (পিরোজপুর)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'নিবন্ধন নং: ২৫/২০২১',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback_outlined, color: Colors.white, size: 26),
            tooltip: 'পরামর্শ ও যোগাযোগ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 26),
            tooltip: 'আমাদের সম্পর্কে',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()),
              );
            },
          ),
        ],
      ),
      body: const HomeScreen(),
    );
  }
}

// ================= ১. হোম স্ক্রিন =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _bloodRequests = [];

  @override
  void initState() {
    super.initState();
    _cleanExpiredRequests();
  }

  void _cleanExpiredRequests() {
    setState(() {
      _bloodRequests.removeWhere((req) {
        try {
          DateTime neededDate = DateTime.parse(req['neededDateRaw'] ?? req['neededDate']);
          DateTime expiryDate = neededDate.add(const Duration(days: 10));
          return DateTime.now().isAfter(expiryDate);
        } catch (e) {
          return false;
        }
      });
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {}
  }

  void _showCommentDialog(Map<String, dynamic> request) {
    if (!UserSession.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কমেন্ট করতে হলে ডোনার হিসেবে লগইন করতে হবে!')),
      );
      return;
    }

    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('রক্ত দেওয়ার আগ্রহ / কমেন্ট করুন'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(labelText: 'আপনার বার্তা লিখুন...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.isNotEmpty) {
                setState(() {
                  String donorName = UserSession.donorData['name'] ?? 'ডোনার';
                  if (request['comments'] == null) {
                    request['comments'] = <String>[];
                  }
                  request['comments'].add('$donorName: ${commentController.text}');
                });
                Navigator.pop(context);
              }
            },
            child: const Text('পোস্ট করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DonorSearchPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: const Text('ডোনার খুঁজুন',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (UserSession.isLoggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DonorProfilePage(donorData: UserSession.donorData),
                          ),
                        ).then((_) => setState(() {}));
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DonorLoginPage()),
                        ).then((_) => setState(() {}));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.person, color: Colors.white),
                    label: Text(
                      UserSession.isLoggedIn ? 'প্রোফাইল' : 'ডোনার লগইন',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddDonorPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text('ডোনার সাইনআপ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'জরুরী রক্তের আবেদনসমূহ:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 10),
            _bloodRequests.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text('বর্তমানে কোনো রক্তের আবেদন নেই', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _bloodRequests.length,
                    itemBuilder: (context, index) {
                      final req = _bloodRequests[index];
                      List comments = req['comments'] ?? [];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('· রোগীর নাম: ${req['patientName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Chip(
                                    backgroundColor: Colors.red,
                                    label: Text(
                                      'গ্রুপ: ${req['bloodGroup']}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Text('· রোগের ধরন: ${req['problem']}'),
                              Text('· ব্লাড নেওয়ার স্থান: ${req['location']}'),
                              Text('· কত ব্যাগ লাগবে: ${req['bags']} ব্যাগ'),
                              Text('· ব্লাড কখন প্রয়োজন: ${req['neededDate']}'),
                              Text('· রোগী/রোগীর প্রতিনিধির মোবাইল নম্বর: ${req['phone']}'),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _makePhoneCall(req['phone']),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    icon: const Icon(Icons.phone, color: Colors.white, size: 16),
                                    label: const Text('কল করুন', style: TextStyle(color: Colors.white)),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _showCommentDialog(req),
                                    icon: const Icon(Icons.comment, color: Colors.blue),
                                    label: Text('কমেন্ট (${comments.length})'),
                                  ),
                                ],
                              ),
                              if (comments.isNotEmpty) ...[
                                const Divider(),
                                const Text('ডোনারদের কমেন্ট:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ...comments.map((c) => Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text('• $c', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                    )),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newReq = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRequestPage()),
          );
          if (newReq != null) {
            setState(() {
              _bloodRequests.insert(0, newReq);
              _cleanExpiredRequests();
            });
          }
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.post_add, color: Colors.white),
        label: const Text('রক্তের আবেদন পোস্ট করুন',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ================= ২. ডোনার সার্চ পেজ =================
class DonorSearchPage extends StatefulWidget {
  const DonorSearchPage({super.key});

  @override
  State<DonorSearchPage> createState() => _DonorSearchPageState();
}

class _DonorSearchPageState extends State<DonorSearchPage> {
  String _selectedBloodGroup = 'A+';
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<Map<String, dynamic>> _donors = [];

  bool _isEligibleToDonate(String gender, String lastDateStr) {
    try {
      DateTime lastDate = DateTime.parse(lastDateStr);
      DateTime now = DateTime.now();
      int monthsDifference = (now.year - lastDate.year) * 12 + now.month - lastDate.month;
      
      if (gender == 'পুরুষ') {
        return monthsDifference >= 3;
      } else if (gender == 'নারী') {
        return monthsDifference >= 4;
      }
    } catch (e) {
      return true;
    }
    return false;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDonors = _donors.where((d) => d['bloodGroup'] == _selectedBloodGroup).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ডোনার খুঁজুন')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedBloodGroup,
                    decoration: const InputDecoration(labelText: 'ব্লাড গ্রুপ নির্বাচন করুন', border: OutlineInputBorder()),
                    items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                    onChanged: (val) => setState(() => _selectedBloodGroup = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: filteredDonors.isEmpty
                  ? const Center(child: Text('এই গ্রুপে কোনো ডোনার পাওয়া যায়নি'))
                  : ListView.builder(
                      itemCount: filteredDonors.length,
                      itemBuilder: (context, index) {
                        final donor = filteredDonors[index];
                        bool isEligible = _isEligibleToDonate(donor['gender'] ?? 'পুরুষ', donor['lastDonationDate'] ?? '2026-01-01');

                        return Card(
                          color: isEligible ? Colors.green.shade50 : Colors.grey.shade100,
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(donor['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                if (isEligible)
                                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                              ],
                            ),
                            subtitle: Text(
                              'লিঙ্গ: ${donor['gender'] ?? 'পুরুষ'}\nমোবাইল: ${donor['phone']}\nঠিকানা: ${donor['address']}\nশেষ দান: ${donor['lastDonationDate']} (${isEligible ? "রক্তদানে প্রস্তুত" : "বিরতিতে আছেন"})',
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () => _makePhoneCall(donor['phone']),
                              style: ElevatedButton.styleFrom(backgroundColor: isEligible ? Colors.green : Colors.grey),
                              icon: const Icon(Icons.phone, color: Colors.white, size: 16),
                              label: const Text('কল', style: TextStyle(color: Colors.white)),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ৩. ডোনার সাইনআপ পেজ =================
class AddDonorPage extends StatefulWidget {
  const AddDonorPage({super.key});

  @override
  State<AddDonorPage> createState() => _AddDonorPageState();
}

class _AddDonorPageState extends State<AddDonorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _lastDonationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _totalDonationsController = TextEditingController(text: '0');
  
  String _selectedBloodGroup = 'A+';
  String _selectedGender = 'পুরুষ';
  bool _isSaving = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _genders = ['পুরুষ', 'নারী'];

  Future<void> _saveDonor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await GoogleSheetService.addDonor(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      gender: _selectedGender,
      address: _addressController.text.trim(),
      lastDonationDate: _lastDonationController.text.trim(),
      password: _passwordController.text.trim(),
      totalDonations: _totalDonationsController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সাইনআপ সফল হয়েছে!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ডোনার সাইনআপ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'নাম'), validator: (v) => v!.isEmpty ? 'নাম লিখুন' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর'), validator: (v) => v!.isEmpty ? 'নম্বর লিখুন' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'ইমেইল'), validator: (v) => v!.isEmpty ? 'ইমেইল লিখুন' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'পাসওয়ার্ড'), validator: (v) => v!.length < 6 ? 'কমপক্ষে ৬ ডিজিট দিন' : null),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'ব্লাড গ্রুপ'),
                items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(labelText: 'লিঙ্গ (Gender)'),
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedGender = v!),
              ),
              const SizedBox(height: 10),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'ঠিকানা'), validator: (v) => v!.isEmpty ? 'ঠিকানা লিখুন' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _totalDonationsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পূর্বে কতবার রক্ত দিয়েছেন?')),
              const SizedBox(height: 10),
              TextFormField(controller: _lastDonationController, decoration: const InputDecoration(labelText: 'শেষ রক্তদানের তারিখ (yyyy-mm-dd)')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveDonor,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('সাইনআপ সম্পন্ন করুন', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= ৪. রক্তের আবেদন পোস্ট করার পেজ =================
class AddRequestPage extends StatefulWidget {
  const AddRequestPage({super.key});

  @override
  State<AddRequestPage> createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _problemController = TextEditingController();
  final _bagsController = TextEditingController(text: '1');
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedBloodGroup = 'A+';
  bool _isSaving = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await GoogleSheetService.addBloodRequest(
      patientName: _patientNameController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      problem: _problemController.text.trim(),
      location: _locationController.text.trim(),
      bags: _bagsController.text.trim(),
      neededDate: _dateController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    Map<String, dynamic> newPost = {
      'patientName': _patientNameController.text.trim(),
      'bloodGroup': _selectedBloodGroup,
      'problem': _problemController.text.trim(),
      'location': _locationController.text.trim(),
      'bags': _bagsController.text.trim(),
      'neededDate': _dateController.text.trim(),
      'neededDateRaw': _dateController.text.trim(),
      'phone': _phoneController.text.trim(),
      'comments': <String>[]
    };

    if (!mounted) return;
    Navigator.pop(context, newPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('রক্তের আবেদন পোস্ট করুন')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _patientNameController, decoration: const InputDecoration(labelText: 'রোগীর নাম'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'কোন গ্রুপের রক্ত দরকার?'),
                items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v!),
              ),
              const SizedBox(height: 10),
              TextFormField(controller: _problemController, decoration: const InputDecoration(labelText: 'রোগের ধরন'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'ব্লাড নেওয়ার স্থান'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _bagsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'কত ব্যাগ লাগবে?'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'ব্লাড কখন প্রয়োজন (yyyy-mm-dd)'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'রোগী/রোগীর প্রতিনিধির মোবাইল নম্বর'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitRequest,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('পোস্ট করুন', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= ৫. লগইন পেজ =================
class DonorLoginPage extends StatefulWidget {
  const DonorLoginPage({super.key});

  @override
  State<DonorLoginPage> createState() => _DonorLoginPageState();
}

class _DonorLoginPageState extends State<DonorLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      Map<String, dynamic> sampleDonor = {
        'name': 'ডোনার',
        'phone': '01700000000',
        'email': _emailController.text,
        'bloodGroup': 'A+',
        'gender': 'পুরুষ',
        'address': 'পিরোজপুর',
        'totalDonations': '0',
        'lastDonationDate': '2026-01-01'
      };
      await UserSession.saveLogin(sampleDonor);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ডোনার লগইন')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'ইমেইল বা মোবাইল')),
            const SizedBox(height: 10),
            TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'পাসওয়ার্ড')),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('পাসওয়ার্ড ভুলে গেছেন?'),
                    content: const Text('পাসওয়ার্ড পুনরুদ্ধারের জন্য অনুগ্রহ করে সংগঠনের পরিচালক/অ্যাডমিনের সাথে যোগাযোগ করুন।'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ঠিক আছে'))],
                  ),
                );
              },
              child: const Text('পাসওয়ার্ড ভুলে গেছেন?', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('লগইন করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ৬. ডোনার প্রোফাইল পেজ =================
class DonorProfilePage extends StatelessWidget {
  final Map<String, dynamic> donorData;
  const DonorProfilePage({super.key, required this.donorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ডোনার প্রোফাইল'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await UserSession.logout();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('নাম: ${donorData['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('লিঙ্গ: ${donorData['gender'] ?? 'পুরুষ'}'),
            Text('মোবাইল: ${donorData['phone']}'),
            Text('ব্লাড গ্রুপ: ${donorData['bloodGroup']}'),
            Text('ঠিকানা: ${donorData['address']}'),
            Text('মোট রক্তদান: ${donorData['totalDonations']} বার'),
            Text('শেষ রক্তদান: ${donorData['lastDonationDate']}'),
          ],
        ),
      ),
    );
  }
}

// ================= ৭. পরামর্শ ও যোগাযোগ পেজ =================
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      bool success = await GoogleSheetService.addFeedback(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('আপনার পরামর্শ সফলভাবে জমা হয়েছে!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('দুঃখিত, আবার চেষ্টা করুন')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পরামর্শ ও যোগাযোগ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'আপনার মূল্যবান মতামত বা অভিযোগ আমাদের জানান:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'নাম',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'দয়া করে আপনার নাম লিখুন' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'মোবাইল',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'দয়া করে আপনার মোবাইল নম্বর লিখুন' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'আপনার পরামর্শ/মন্তব্য/অভিযোগ',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'দয়া করে আপনার মন্তব্য লিখুন' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'জমা দিন',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= ৮. আমাদের সম্পর্কে পেজ =================
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchFacebookGroup() async {
    final Uri url = Uri.parse('https://www.facebook.com/groups/334400873857095');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // প্রয়োজনীয় এরর হ্যান্ডেলিং
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আমাদের সম্পর্কে')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'রক্তকণা যুব সামাজিক সংগঠন',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text('পিরোজপুর | নিবন্ধন নং: ২৫/২০২১', style: TextStyle(color: Colors.grey)),
            const Divider(height: 30),
            const ListTile(
              title: Text('সংগঠনের পরিচালক', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('এইচ এম মামুন\nমোবাইল: 01638557040'),
            ),
            const ListTile(
              title: Text('অ্যাপ প্রস্তুতকারী', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('মোঃ মোস্তাফিজুর রহমান\nমোবাইল: 01978953539'),
            ),
            const Divider(height: 30),
            ElevatedButton.icon(
              onPressed: _launchFacebookGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.facebook, color: Colors.white, size: 24),
              label: const Text(
                'আমাদের ফেসবুক গ্রুপে যুক্ত হোন',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}