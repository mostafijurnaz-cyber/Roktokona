import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoktokonaApp());
}

// গ্লোবাল ভ্যারিয়েবল বা স্টেট দিয়ে ডোনার লগইন চেক করার সুবিধা
bool isGlobalDonorLoggedIn = false;
Map<String, dynamic>? loggedInDonorData;

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

const String webAppUrl =
    "https://script.google.com/macros/s/AKfycbz3rqJwoEFcfDd0w3ho54PtckVTRUMkCs6cSdp-cBOpVipYIIQHjGO1cq8zbgGhM9yt_A/exec";

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
              icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
              tooltip: 'আমাদের সম্পর্কে',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(icon: Icon(Icons.home), text: "হোম ও রক্তদাতা"),
              Tab(icon: Icon(Icons.bloodtype), text: "রক্তের প্রয়োজন"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomeScreen(),
            BloodRequestTab(),
          ],
        ),
      ),
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
  List<dynamic> _allDonors = [];
  List<dynamic> _displayedDonors = [];
  bool _isLoading = true;
  bool _hasSearched = false;
  String _selectedBloodGroup = 'A+';
  int _totalDonationsCount = 0;
  int _benefitedCount = 0;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _fetchDonors();
  }

  Future<void> _fetchDonors() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(webAppUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        int totalDonations = 0;
        for (var donor in data) {
          int count = int.tryParse(donor['totalDonations'].toString()) ?? 0;
          totalDonations += count;
        }

        setState(() {
          _allDonors = data;
          _totalDonationsCount = totalDonations;
          _benefitedCount = totalDonations;
          _isLoading = false;
          if (_hasSearched) {
            _searchDonors();
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _searchDonors() {
    setState(() {
      _hasSearched = true;
      _displayedDonors = _allDonors
          .where((donor) => donor['bloodGroup'] == _selectedBloodGroup)
          .toList();
    });
  }

  bool _isEligibleToDonate(String? lastDonationDateStr) {
    if (lastDonationDateStr == null || lastDonationDateStr.trim().isEmpty) return true;
    try {
      DateTime lastDate = DateTime.parse(lastDonationDateStr);
      DateTime today = DateTime.now();
      return today.difference(lastDate).inDays >= 90;
    } catch (e) {
      return true;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(launchUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('কল দেওয়া সম্ভব হচ্ছে না: $cleanPhone')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchDonors,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/logo.png',
                              height: 55,
                              width: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.redAccent,
                                child: Icon(Icons.bloodtype,
                                    size: 36, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'মোট রক্তদান: $_totalDonationsCount ব্যাগ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.redAccent),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'উপকৃত হয়েছেন: $_benefitedCount জন রোগী',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '"রক্ত দিতে কার্পণ্য নয়! রক্ত দিবো মোরা স্বেচ্ছায়"',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DonorLoginPage()),
                        );
                        if (res == true) setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: Text(
                        isGlobalDonorLoggedIn ? 'প্রোফাইল (লগইনড)' : 'ডোনার লগইন',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddDonorPage()),
                        );
                        if (res == true) _fetchDonors();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text('ডোনার রেজিস্ট্রেশন',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedBloodGroup,
                          decoration: const InputDecoration(
                            labelText: 'ব্লাড গ্রুপ নির্বাচন করুন',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: _bloodGroups
                              .map((bg) =>
                                  DropdownMenuItem(value: bg, child: Text(bg)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedBloodGroup = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _searchDonors,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text('সার্চ',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator()))
                  : !_hasSearched
                      ? const Center(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('ব্লাড গ্রুপ দিয়ে সার্চ করুন')))
                      : _displayedDonors.isEmpty
                          ? const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('কোনো ডোনার পাওয়া যায়নি',
                                      style: TextStyle(color: Colors.red))))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _displayedDonors.length,
                              itemBuilder: (context, index) {
                                final donor = _displayedDonors[index];
                                final bool isReady = _isEligibleToDonate(
                                    donor['lastDonationDate']);
                                final Color statusColor =
                                    isReady ? Colors.green : Colors.red;
                                final String phone =
                                    donor['phone']?.toString() ?? '';
                                final String photoUrl =
                                    donor['photo']?.toString() ?? '';

                                return Card(
                                  color: isReady
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: statusColor, width: 1.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: photoUrl.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 25,
                                            backgroundImage:
                                                NetworkImage(photoUrl),
                                          )
                                        : CircleAvatar(
                                            radius: 25,
                                            backgroundColor: statusColor,
                                            foregroundColor: Colors.white,
                                            child: Text(donor['bloodGroup'] ?? ''),
                                          ),
                                    title: Text(donor['name'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      'মোবাইল: $phone\nঠিকানা: ${donor['address']}\nমোট রক্ত দিয়েছেন: ${donor['totalDonations']} বার\nশেষ রক্তদান: ${donor['lastDonationDate']?.isEmpty ?? true ? "তথ্য নেই" : donor['lastDonationDate']}',
                                    ),
                                    trailing: isReady
                                        ? ElevatedButton.icon(
                                            onPressed: () =>
                                                _makePhoneCall(phone),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                            icon: const Icon(Icons.phone,
                                                color: Colors.white, size: 16),
                                            label: const Text('কল করুন',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                          )
                                        : const Text('অপ্রস্তুত',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= ২. ডোনার রেজিস্ট্রেশন (ছবি সহ) =================
class AddDonorPage extends StatefulWidget {
  const AddDonorPage({super.key});

  @override
  State<AddDonorPage> createState() => _AddDonorPageState();
}

class _AddDonorPageState extends State<AddDonorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _lastDonationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _totalDonationsController = TextEditingController(text: '0');
  String _selectedBloodGroup = 'A+';
  File? _donorImage;
  bool _isSaving = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setState(() {
        _donorImage = File(image.path);
      });
    }
  }

  Future<void> _saveDonor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final Uri url = Uri.parse(webAppUrl).replace(queryParameters: {
        'action': 'addDonor',
        'name': _nameController.text,
        'phone': _phoneController.text,
        'bloodGroup': _selectedBloodGroup,
        'address': _addressController.text,
        'lastDonationDate': _lastDonationController.text,
        'password': _passwordController.text,
        'totalDonations': _totalDonationsController.text,
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('সফলভাবে ডোনার রেজিস্টার হয়েছে!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ত্রুটি ঘটেছে: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('নতুন ডোনার রেজিস্টার')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.red.shade100,
                  backgroundImage:
                      _donorImage != null ? FileImage(_donorImage!) : null,
                  child: _donorImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.red, size: 28),
                            Text('ছবি দিন',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.red)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'নাম'),
                  validator: (v) => v!.isEmpty ? 'নাম লিখুন' : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'মোবাইল নম্বর'),
                  validator: (v) => v!.isEmpty ? 'নম্বর লিখুন' : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'পাসওয়ার্ড'),
                  validator: (v) => v!.isEmpty ? 'পাসওয়ার্ড লিখুন' : null),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'ব্লাড গ্রুপ'),
                items: _bloodGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'ঠিকানা'),
                  validator: (v) => v!.isEmpty ? 'ঠিকানা লিখুন' : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _totalDonationsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'পূর্বে কতবার রক্ত দিয়েছেন?')),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _lastDonationController,
                  decoration: const InputDecoration(
                      labelText: 'শেষ রক্তদানের তারিখ (yyyy-mm-dd)')),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDonor,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('রেজিস্টার করুন',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= ৩. রক্তের প্রয়োজন ট্যাব =================
class BloodRequestTab extends StatefulWidget {
  const BloodRequestTab({super.key});

  @override
  State<BloodRequestTab> createState() => _BloodRequestTabState();
}

class _BloodRequestTabState extends State<BloodRequestTab> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final Uri url = Uri.parse(webAppUrl)
          .replace(queryParameters: {'action': 'getRequests'});
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _requests = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(launchUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('কল দেওয়া সম্ভব হচ্ছে না: $cleanPhone')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Card(
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.orange, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange, size: 24),
                        SizedBox(width: 8),
                        Text('রক্ত গ্রহীতাদের জন্য জরুরী নির্দেশনা:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.brown)),
                      ],
                    ),
                    Divider(),
                    Text('১. ডোনারকে অবশ্যই যথাসম্ভব যাতায়াত খরচ প্রদান করবেন।'),
                    Text(
                        '২. রক্তদানের আগে ও পরে ডোনারের শারীরিক খোঁজ-খবর রাখা আবশ্যিক।'),
                    Text(
                        '৩. ব্লাড পরীক্ষার সমস্ত হাসপাতাল/মেডিকেল খরচ রোগীপক্ষ বহন করবে।'),
                    Text('৪. স্বেচ্ছাসেবক ডোনারকে সর্বোচ্চ সম্মান প্রদর্শন করুন।'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator()))
                : _requests.isEmpty
                    ? const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('বর্তমানে কোনো রক্তের পোস্ট নেই')))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _requests.length,
                        itemBuilder: (context, index) {
                          final req = _requests[index];
                          final phone = req['phone']?.toString() ?? '';
                          
                          final String patientName = (req['patientName'] != null &&
                                  req['patientName'].toString().trim().isNotEmpty &&
                                  req['patientName'].toString() != 'null')
                              ? req['patientName']
                              : 'তথ্য নেই';

                          final String neededDate = (req['neededDate'] != null &&
                                  req['neededDate'].toString().trim().isNotEmpty &&
                                  req['neededDate'].toString() != 'null')
                              ? req['neededDate']
                              : 'তারিখ দেওয়া হয়নি';

                          final String bags = req['bags']?.toString() ?? '1';
                          final String problem = req['patientProblem'] ?? 'অন্যান্য';
                          final String location = req['location'] ?? 'লোকেশন নেই';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            color: Colors.red.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      child: Text(req['bloodGroup'] ?? ''),
                                    ),
                                    title: Text(
                                        'রোগী: $patientName ($bags ব্যাগ)',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      'রোগের ধরন: $problem\nতারিখ: $neededDate\nলোকেশন: $location\nযোগাযোগ: $phone',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.phone,
                                          color: Colors.green, size: 28),
                                      onPressed: () => _makePhoneCall(phone),
                                    ),
                                    isThreeLine: true,
                                  ),
                                  if (isGlobalDonorLoggedIn) ...[
                                    const Divider(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        icon: const Icon(Icons.check_circle_outline, size: 18),
                                        label: const Text('রক্ত দেওয়া হয়েছে (সম্পন্ন করুন)'),
                                        onPressed: () {
                                          setState(() {
                                            _requests.removeAt(index);
                                          });
                                          // এখানে ScaffoldMessenger.contextOf(context) এর বদলে সঠিক ScaffoldMessenger.of(context) ব্যবহার করা হয়েছে
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('রক্তদানের অনুরোধটি সম্পন্ন করা হয়েছে এবং পোস্টটি সরানো হয়েছে!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRequestPage()),
          );
          if (result == true) _fetchRequests();
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.post_add, color: Colors.white),
        label: const Text('রক্তের আবেদন পোস্ট করুন',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Future<void> _saveRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final Uri url = Uri.parse(webAppUrl).replace(queryParameters: {
        'action': 'addRequest',
        'patientName': _patientNameController.text,
        'patientProblem': _problemController.text,
        'bloodGroup': _selectedBloodGroup,
        'bags': _bagsController.text,
        'neededDate': _dateController.text,
        'location': _locationController.text,
        'phone': _phoneController.text,
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('রক্তের আবেদন সফলভাবে পোস্ট করা হয়েছে!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ত্রুটি ঘটেছে: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
              TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(labelText: 'রোগীর নাম'),
                  validator: (v) => v!.isEmpty ? 'রোগীর নাম লিখুন' : null),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration:
                    const InputDecoration(labelText: 'প্রয়োজনীয় ব্লাড গ্রুপ'),
                items: _bloodGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v!),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: _bagsController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'কত ব্যাগ লাগবে?'),
                        validator: (v) =>
                            v!.isEmpty ? 'পরিমাণ লিখুন' : null),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                            labelText: 'রক্ত লাগার তারিখ (যেমন: 12-Aug)'),
                        validator: (v) =>
                            v!.isEmpty ? 'তারিখ লিখুন' : null),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _problemController,
                  decoration: const InputDecoration(
                      labelText: 'রোগের ধরন / সমস্যা (যেমন: ডেলিভারি)'),
                  validator: (v) => v!.isEmpty ? 'সমস্যা লিখুন' : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                      labelText: 'হাসপাতাল / রক্তদানের স্থান'),
                  validator: (v) => v!.isEmpty ? 'লোকেশন লিখুন' : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(labelText: 'যোগাযোগের মোবাইল নম্বর'),
                  validator: (v) => v!.isEmpty ? 'নম্বর লিখুন' : null),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRequest,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('আবেদন পোস্ট করুন',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= ৫. আমাদের সম্পর্কে পেজ =================
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openFacebookGroup() async {
    final Uri url =
        Uri.parse("https://www.facebook.com/groups/334400873857095/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
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
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/logo.png',
                height: 90,
                width: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.bloodtype, size: 50, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'রক্তকণা যুব সামাজিক সংগঠন',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
            ),
            const Text(
              'পিরোজপুর | নিবন্ধন নং: ২৫/২০২১',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'রক্তদান, জীবনদান',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 30, thickness: 1),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.admin_panel_settings, color: Colors.white)),
                title: const Text('সংগঠনের পরিচালক',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('এইচ এম মামুন\nমোবাইল: 01638557040'),
                trailing: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () => _makeCall('01638557040')),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.code, color: Colors.white)),
                title: const Text('অ্যাপ প্রস্তুতকারী',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('মোঃ মোস্তাফিজুর রহমান\nমোবাইল: 01978953539'),
                trailing: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () => _makeCall('01978953539')),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1877F2),
                    child: Icon(Icons.groups, color: Colors.white)),
                title: const Text('ফেসবুক গ্রুপে যুক্ত হউন',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1877F2))),
                subtitle: const Text('অফিশিয়াল গ্রুপে জয়েন করুন'),
                trailing:
                    const Icon(Icons.open_in_new, color: Color(0xFF1877F2)),
                onTap: _openFacebookGroup,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ৬. ডোনার লগইন ও প্রোফাইল =================
class DonorLoginPage extends StatefulWidget {
  const DonorLoginPage({super.key});

  @override
  State<DonorLoginPage> createState() => _DonorLoginPageState();
}

class _DonorLoginPageState extends State<DonorLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoggingIn = true);

    try {
      final Uri url = Uri.parse(webAppUrl).replace(queryParameters: {
        'action': 'loginDonor',
        'phone': _phoneController.text,
        'password': _passwordController.text,
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (!mounted) return;
        if (resData['result'] == 'success') {
          isGlobalDonorLoggedIn = true;
          loggedInDonorData = resData['donor'];

          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DonorProfileEditPage(donorData: resData['donor']),
            ),
          );
          if (updated == true) Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ভুল নম্বর অথবা পাসওয়ার্ড!')));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ত্রুটি ঘটেছে: $e')));
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ডোনার লগইন')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle,
                  size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'মোবাইল নম্বর', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'নম্বর লিখুন' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'পাসওয়ার্ড', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'পাসওয়ার্ড লিখুন' : null,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoggingIn ? null : _login,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: _isLoggingIn
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('লগইন করুন',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DonorProfileEditPage extends StatefulWidget {
  final Map<String, dynamic> donorData;
  const DonorProfileEditPage({super.key, required this.donorData});

  @override
  State<DonorProfileEditPage> createState() => _DonorProfileEditPageState();
}

class _DonorProfileEditPageState extends State<DonorProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _addressController;
  late TextEditingController _lastDonationController;
  late TextEditingController _totalDonationsController;
  late String _selectedBloodGroup;
  File? _donorImage;

  bool _isSaving = false;
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.donorData['name']);
    _phoneController = TextEditingController(text: widget.donorData['phone']);
    _passwordController =
        TextEditingController(text: widget.donorData['password']);
    _addressController =
        TextEditingController(text: widget.donorData['address']);
    _lastDonationController =
        TextEditingController(text: widget.donorData['lastDonationDate']);
    _totalDonationsController = TextEditingController(
        text: widget.donorData['totalDonations'].toString());
    _selectedBloodGroup = _bloodGroups.contains(widget.donorData['bloodGroup'])
        ? widget.donorData['bloodGroup']
        : 'A+';
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setState(() {
        _donorImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final Uri url = Uri.parse(webAppUrl).replace(queryParameters: {
        'action': 'updateDonorProfile',
        'phone': widget.donorData['phone'],
        'oldPassword': widget.donorData['password'],
        'name': _nameController.text,
        'newPhone': _phoneController.text,
        'newPassword': _passwordController.text,
        'bloodGroup': _selectedBloodGroup,
        'address': _addressController.text,
        'lastDonationDate': _lastDonationController.text,
        'totalDonations': _totalDonationsController.text,
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('প্রোফাইল তথ্য সেভ হয়েছে!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ত্রুটি ঘটেছে: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _quickDonateIncrement() async {
    int currentTotal = int.tryParse(_totalDonationsController.text) ?? 0;
    int updatedTotal = currentTotal + 1;
    String todayDate = DateTime.now().toString().split(' ')[0];

    setState(() => _isSaving = true);
    try {
      final Uri url = Uri.parse(webAppUrl).replace(queryParameters: {
        'action': 'updateDonorProfile',
        'phone': widget.donorData['phone'],
        'oldPassword': widget.donorData['password'],
        'lastDonationDate': todayDate,
        'totalDonations': updatedTotal.toString(),
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'অভিনন্দন! মোট রক্তদান: $updatedTotal বার আপডেট হয়েছে।')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ত্রুটি ঘটেছে: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('প্রোফাইল এডিট')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.red.shade100,
                  backgroundImage:
                      _donorImage != null ? FileImage(_donorImage!) : null,
                  child: _donorImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.red, size: 28),
                            Text('ছবি পাল্টান',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.red)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                          child: Text('আজ রক্তদান করেছেন?',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _quickDonateIncrement,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('আজ দিয়েছি (+1)',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'নাম')),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'মোবাইল নম্বর')),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'নতুন পাসওয়ার্ড')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'ব্লাড গ্রুপ'),
                items: _bloodGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'ঠিকানা')),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _totalDonationsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'মোট রক্তদান')),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _lastDonationController,
                  decoration: const InputDecoration(
                      labelText: 'শেষ রক্তদানের তারিখ (yyyy-mm-dd)')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('সেভ করুন',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}