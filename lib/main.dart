import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

// ================= গুগল শিট সার্ভিস =================
class GoogleSheetService {
  static const String url = 'https://script.google.com/macros/s/AKfycby4sZPx79LJvvX6DEi3KvI91jm-dTmJ8K_EhQ1RLOgRgWmAmjGPX4ij-Ya3IdSH-lx0TA/exec';

  static String normalizePhone(String value) {
    String digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('00880')) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('880') && digits.length == 13) {
      return '0${digits.substring(3)}';
    }
    return digits;
  }

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
    String photo = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "addDonor",
          "name": name, 
          "phone": normalizePhone(phone), 
          "email": email,
          "bloodGroup": bloodGroup, 
          "gender": gender, 
          "address": address,
          "lastDonationDate": lastDonationDate, 
          "password": password,
          "totalDonations": totalDonations, 
          "photo": photo,
          "role": "Donor",
          "points": "0",
          "badge": "Bronze",
          "timestamp": DateTime.now().toString(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateDonor({
    required String name,
    required String phone,
    required String email,
    required String bloodGroup,
    required String gender,
    required String address,
    required String lastDonationDate,
    required String password,
    required String totalDonations,
    required String photo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "updateDonor",
          "name": name, 
          "phone": normalizePhone(phone), 
          "email": email,
          "bloodGroup": bloodGroup, 
          "gender": gender, 
          "address": address,
          "lastDonationDate": lastDonationDate, 
          "password": password,
          "totalDonations": totalDonations, 
          "photo": photo,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateOnlineStatus(String phone, String onlineStatus) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "updateOnlineStatus",
          "phone": normalizePhone(phone),
          "onlineStatus": onlineStatus,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getDonors() async {
    try {
      final response = await http.get(Uri.parse('$url?action=getDonors'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          Map<String, dynamic> map = Map<String, dynamic>.from(item);
          map.forEach((key, value) {
            map[key] = value?.toString() ?? '';
          });
          return map;
        }).toList();
      }
    } catch (e) {
      // Error handling
    }
    return [];
  }

  static Future<bool> addBloodRequest({
    required String patientName, 
    required String bloodGroup,
    required String problem, 
    required String location,
    required String bags, 
    required String neededDate, 
    required String phone,
    required String recipientName, 
    required String recipientAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "addRequest",
          "patientName": patientName, 
          "bloodGroup": bloodGroup,
          "problem": problem, 
          "location": location, 
          "bags": bags,
          "neededDate": neededDate, 
          "phone": normalizePhone(phone),
          "recipientName": recipientName, 
          "recipientAddress": recipientAddress,
          "timestamp": DateTime.now().toString(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteBloodRequest(String patientName, String phone) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "deleteRequest",
          "patientName": patientName,
          "phone": normalizePhone(phone),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getBloodRequests() async {
    try {
      final response = await http.get(Uri.parse('$url?action=getRequests'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          Map<String, dynamic> map = Map<String, dynamic>.from(item);
          map.forEach((key, value) {
            map[key] = value?.toString() ?? '';
          });
          return map;
        }).toList();
      }
    } catch (e) {
      // Error handling
    }
    return [];
  }

  static Future<bool> acceptBloodRequest({
    required String requestId,
    required String donorPhone,
    required String donorName,
    required String donationDate,
    required String bags,
    required String rating,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "acceptRequest",
          "requestId": requestId,
          "donorPhone": normalizePhone(donorPhone),
          "donorName": donorName,
          "donationDate": donationDate,
          "bags": bags,
          "rating": rating,
          "comment": comment,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> approveDonation({
    required String requestId,
    required String donorPhone,
    required String bags,
    required String donationDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "approveDonation",
          "requestId": requestId,
          "donorPhone": normalizePhone(donorPhone),
          "bags": bags,
          "donationDate": donationDate,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getAdminCredentials() async {
    try {
      final response = await http.get(Uri.parse('$url?action=getAdmin'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          Map<String, dynamic> map = Map<String, dynamic>.from(item);
          map.forEach((key, value) {
            map[key] = value?.toString() ?? '';
          });
          return map;
        }).toList();
      }
    } catch (e) {
      // Error handling
    }
    return [];
  }

  static Future<bool> addFeedback({required String name, required String phone, required String message}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "addFeedback",
          "name": name,
          "phone": normalizePhone(phone),
          "message": message,
          "timestamp": DateTime.now().toString()
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getInbox(String userPhone) async {
    try {
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {
          'action': 'getInbox',
          'user': normalizePhone(userPhone),
        }),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          Map<String, dynamic> map = Map<String, dynamic>.from(item);
          map.forEach((key, value) {
            map[key] = value?.toString() ?? '';
          });
          return map;
        }).toList();
      }
    } catch (e) {
      // Error handling
    }
    return [];
  }

  static Future<int> getUnreadCount(String userPhone) async {
    try {
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {
          'action': 'getUnreadCount',
          'user': normalizePhone(userPhone),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('count')) {
          return int.tryParse(data['count'].toString()) ?? 0;
        }
      }
    } catch (e) {
      // Error handling
    }
    return 0;
  }

  static Future<bool> markMessagesRead(String userPhone, String peerPhone) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "markMessagesRead",
          "user": normalizePhone(userPhone),
          "peer": normalizePhone(peerPhone),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// ================= সেশন ম্যানেজমেন্ট =================
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
    String phoneVal = donorData['Phone'] ?? donorData['phone'] ?? donorData['Mobile'] ?? '';
    if (phoneVal.isNotEmpty) {
      await GoogleSheetService.updateOnlineStatus(phoneVal, 'Offline');
    }
    isLoggedIn = false;
    donorData = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('donorData');
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

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
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
                'assets/logo.png', height: 38, width: 38, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.bloodtype, size: 36, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('রক্তকণা (পিরোজপুর)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('নিবন্ধন নং: ২৫/২০২০', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final prefs = snapshot.data!;
              String? postedPhone = prefs.getString('guest_poster_phone');
              String myPhone = UserSession.isLoggedIn
                  ? (UserSession.donorData['Phone'] ?? UserSession.donorData['phone'] ?? UserSession.donorData['Mobile'] ?? '')
                  : (postedPhone ?? '');
              if (myPhone.isEmpty) return const SizedBox();

              return FutureBuilder<int>(
                future: GoogleSheetService.getUnreadCount(myPhone),
                builder: (context, unreadSnapshot) {
                  int unreadCount = unreadSnapshot.data ?? 0;

                  return Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.red.shade900,
                    offset: const Offset(-4, 4),
                    child: IconButton(
                      icon: const Icon(Icons.forum_outlined, color: Colors.white, size: 26),
                      tooltip: 'আমার ইনবক্স',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InboxPage(myPhone: myPhone)),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 26),
            tooltip: 'এডমিন লগইন',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginPage())),
          ),
          IconButton(
            icon: const Icon(Icons.feedback_outlined, color: Colors.white, size: 26),
            tooltip: 'পরামর্শ',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackPage())),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 26),
            tooltip: 'আমাদের সম্পর্কে',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage())),
          ),
        ],
      ),
      body: const HomeScreen(),
    );
  }
}

// ================= হোম স্ক্রিন =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _bloodRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> requests = await GoogleSheetService.getBloodRequests();
    if (!mounted) return;
    setState(() {
      _bloodRequests = requests;
      _isLoading = false;
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
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (UserSession.isLoggedIn) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DonorProfilePage(donorData: UserSession.donorData)))
                              .then((_) => setState(() {}));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DonorLoginPage()))
                              .then((_) => setState(() {}));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
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
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecipientLoginPage())),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.supervised_user_circle, color: Colors.white),
                      label: const Text('সেবাগ্রহীতা লগইন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (!UserSession.isLoggedIn) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDonorPage())),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text('ডোনার সাইনআপ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecipientsListPage())),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.list_alt, color: Colors.white),
                      label: const Text('সেবাগ্রহীতার তালিকা', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text('জরুরী রক্তের আবেদনসমূহ:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
                  : _bloodRequests.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('বর্তমানে কোনো রক্তের আবেদন নেই', style: TextStyle(color: Colors.grey))))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _bloodRequests.length,
                          itemBuilder: (context, index) {
                            final req = _bloodRequests[index];
                            String reqPhone = req['Phone'] ?? req['phone'] ?? req['Mobile'] ?? req['mobile'] ?? '';
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
                                        Text('• রোগীর নাম: ${req['PatientName'] ?? req['patientName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Chip(
                                          backgroundColor: Colors.red,
                                          label: Text('গ্রুপ: ${req['BloodGroup'] ?? req['bloodGroup'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    Text('• সেবাগ্রহীতা: ${req['RecipientName'] ?? req['recipientName'] ?? 'অজানা'}'),
                                    Text('• রোগের ধরন: ${req['Problem'] ?? req['problem'] ?? ''}'),
                                    Text('• ব্লাড নেওয়ার স্থান: ${req['Location'] ?? req['location'] ?? ''}'),
                                    Text('• কত ব্যাগ লাগবে: ${req['Bags'] ?? req['bags'] ?? ''} ব্যাগ'),
                                    Text('• ব্লাড কখন প্রয়োজন: ${req['NeededDate'] ?? req['neededDate'] ?? ''}'),
                                    Text('• মোবাইল নম্বর: $reqPhone'),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _makePhoneCall(reqPhone),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          icon: const Icon(Icons.phone, color: Colors.white, size: 16),
                                          label: const Text('কল করুন', style: TextStyle(color: Colors.white)),
                                        ),
                                        const SizedBox(width: 8),
                                        if (UserSession.isLoggedIn)
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AcceptRequestFormPage(requestData: req),
                                                ),
                                              ).then((_) => _fetchRequests());
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                            icon: const Icon(Icons.check, color: Colors.white, size: 16),
                                            label: const Text('Accept', style: TextStyle(color: Colors.white)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? success = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRequestPage()));
          if (success == true) _fetchRequests();
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.post_add, color: Colors.white),
        label: const Text('রক্তের আবেদন পোস্ট করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ================= সেবাগ্রহীতার তালিকা পেজ =================
class RecipientsListPage extends StatefulWidget {
  const RecipientsListPage({super.key});

  @override
  State<RecipientsListPage> createState() => _RecipientsListPageState();
}

class _RecipientsListPageState extends State<RecipientsListPage> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipients();
  }

  Future<void> _loadRecipients() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> allReqs = await GoogleSheetService.getBloodRequests();
    if (!mounted) return;
    setState(() {
      _requests = allReqs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedByPhone = {};
    for (var r in _requests) {
      String ph = GoogleSheetService.normalizePhone(r['Phone'] ?? r['phone'] ?? '');
      if (ph.isNotEmpty) {
        groupedByPhone.putIfAbsent(ph, () => []).add(r);
      }
    }

    List<Map<String, dynamic>> recipientList = [];
    groupedByPhone.forEach((phone, reqs) {
      var first = reqs.first;
      recipientList.add({
        'phone': phone,
        'name': first['RecipientName'] ?? first['recipientName'] ?? first['PatientName'] ?? 'অজানা',
        'address': first['RecipientAddress'] ?? first['recipientAddress'] ?? first['Location'] ?? '',
        'requests': reqs,
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('সকল সেবাগ্রহীতার তালিকা')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipientList.isEmpty
              ? const Center(child: Text('কোনো সেবাগ্রহীতা পাওয়া যায়নি'))
              : ListView.builder(
                  itemCount: recipientList.length,
                  itemBuilder: (context, index) {
                    var rec = recipientList[index];
                    List reqs = rec['requests'];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text(rec['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('মোবাইল: ${rec['phone']}\nঠিকানা: ${rec['address']}'),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('হিস্টোরি ও রিভিউসমূহ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            ),
                          ),
                          ...reqs.map((r) {
                            return ListTile(
                              title: Text('রোগী: ${r['PatientName'] ?? ''} (${r['BloodGroup'] ?? ''})'),
                              subtitle: Text('তারিখ: ${r['NeededDate'] ?? ''}\nডোনার: ${r['DonorName'] ?? 'কেউ এক্সেপ্ট করেনি'}\nরিভিউ: ${r['Rating'] != null && r['Rating'].toString().isNotEmpty ? '${r['Rating']} স্টার - ${r['Comment'] ?? ''}' : 'রিভিউ নেই'}'),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// ================= সেবাগ্রহীতা লগইন পেজ =================
class RecipientLoginPage extends StatefulWidget {
  const RecipientLoginPage({super.key});

  @override
  State<RecipientLoginPage> createState() => _RecipientLoginPageState();
}

class _RecipientLoginPageState extends State<RecipientLoginPage> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _loginRecipient() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> allReqs = await GoogleSheetService.getBloodRequests();
    String normPhone = GoogleSheetService.normalizePhone(phone);

    List<Map<String, dynamic>> myReqs = allReqs.where((r) {
      String p = GoogleSheetService.normalizePhone(r['Phone'] ?? r['phone'] ?? '');
      return p == normPhone;
    }).toList();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (myReqs.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipientDashboardPage(phone: normPhone, requests: myReqs),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('এই নম্বরে কোনো রক্তের আবেদন পাওয়া যায়নি!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সেবাগ্রহীতা লগইন')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('আপনার মোবাইল নম্বর দিয়ে পূর্বের হিস্টোরি ও রিভিউ দেখুন', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _loginRecipient,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('লগইন / হিস্টোরি দেখুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= সেবাগ্রহীতা ড্যাশবোর্ড =================
class RecipientDashboardPage extends StatelessWidget {
  final String phone;
  final List<Map<String, dynamic>> requests;
  const RecipientDashboardPage({super.key, required this.phone, required this.requests});

  @override
  Widget build(BuildContext context) {
    int totalRequested = requests.length;
    int totalReceived = requests.where((r) => (r['Status'] ?? r['status'] ?? '') == 'Accepted' || (r['DonorName'] != null && r['DonorName'].toString().isNotEmpty)).length;

    return Scaffold(
      appBar: AppBar(title: const Text('সেবাগ্রহীতা ড্যাশবোর্ড')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('মোট ব্লাড চাওয়া হয়েছে', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('$totalRequested', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('ব্লাড পাওয়া গেছে', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('$totalReceived', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text('আপনার আবেদনসমূহের তালিকা ও ডোনার রিভিউ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  var r = requests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('রোগী: ${r['PatientName'] ?? ''} (${r['BloodGroup'] ?? ''})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('স্থান: ${r['Location'] ?? ''}'),
                          Text('ব্যাগ: ${r['Bags'] ?? ''} ব্যাগ'),
                          Text('ডোনার: ${r['DonorName'] ?? 'কেউ এক্সেপ্ট করেনি'}'),
                          Text('রিভিউ: ${r['Rating'] != null && r['Rating'].toString().isNotEmpty ? '${r['Rating']} স্টার - ${r['Comment'] ?? ''}' : 'রিভিউ প্রদান করা হয়নি'}'),
                        ],
                      ),
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

// ================= ডোনার এক্সেপ্ট ফর্ম পেজ =================
class AcceptRequestFormPage extends StatefulWidget {
  final Map<String, dynamic> requestData;
  const AcceptRequestFormPage({super.key, required this.requestData});

  @override
  State<AcceptRequestFormPage> createState() => _AcceptRequestFormPageState();
}

class _AcceptRequestFormPageState extends State<AcceptRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _bagsController = TextEditingController(text: '1');
  final _commentController = TextEditingController();
  String _selectedRating = '5';
  bool _isSaving = false;

  final List<String> _ratings = ['1', '2', '3', '4', '5'];

  Future<void> _submitAcceptance() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    String reqId = widget.requestData['Id'] ?? widget.requestData['id'] ?? widget.requestData['PatientName'] ?? '';
    String donorPhone = UserSession.donorData['Phone'] ?? UserSession.donorData['phone'] ?? UserSession.donorData['Mobile'] ?? '';
    String donorName = UserSession.donorData['Name'] ?? UserSession.donorData['name'] ?? '';

    bool success = await GoogleSheetService.acceptBloodRequest(
      requestId: reqId,
      donorPhone: donorPhone,
      donorName: donorName,
      donationDate: _dateController.text.trim(),
      bags: _bagsController.text.trim(),
      rating: _selectedRating,
      comment: _commentController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('রক্তদানের তথ্য সফলভাবে জমা দেওয়া হয়েছে। এডমিন এপ্রুভ করলে পয়েন্ট যোগ হবে।')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সংরক্ষণ ব্যর্থ হয়েছে!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('রক্তদানের তথ্য ও রিভিউ দিন')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'কত তারিখে ব্লাড দিয়েছেন? (yyyy-mm-dd)')),
              TextFormField(controller: _bagsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'কত ব্যাগ ব্লাড দিয়েছেন?')),
              DropdownButtonFormField<String>(
                value: _selectedRating,
                decoration: const InputDecoration(labelText: 'সেবাগ্রহীতার সন্তুষ্টি ও ব্যবহার (স্টার রেটিং ১-৫)'),
                items: _ratings.map((r) => DropdownMenuItem(value: r, child: Text('$r স্টার'))).toList(),
                onChanged: (v) => setState(() => _selectedRating = v!),
              ),
              TextFormField(controller: _commentController, maxLines: 3, decoration: const InputDecoration(labelText: 'মন্তব্য ও অভিজ্ঞতা')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitAcceptance,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('জমা দিন', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= ইনবক্স পেজ =================
class InboxPage extends StatefulWidget {
  final String myPhone;
  const InboxPage({super.key, required this.myPhone});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _donors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInbox();
  }

  Future<void> _loadInbox() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      GoogleSheetService.getInbox(widget.myPhone),
      GoogleSheetService.getDonors(),
    ]);
    if (!mounted) return;
    setState(() {
      _conversations = results[0];
      _donors = results[1];
      _isLoading = false;
    });
  }

  String _resolveName(String peerPhone) {
    final match = _donors.firstWhere(
      (d) {
        String p = d['Phone'] ?? d['phone'] ?? d['Mobile'] ?? '';
        return GoogleSheetService.normalizePhone(p) ==
            GoogleSheetService.normalizePhone(peerPhone);
      },
      orElse: () => {},
    );
    if (match.isNotEmpty) {
      return match['Name'] ?? match['name'] ?? peerPhone;
    }
    return peerPhone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আমার ইনবক্স')),
      body: RefreshIndicator(
        onRefresh: _loadInbox,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _conversations.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Text('এখনো কোনো কথোপকথন নেই', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final convo = _conversations[index];
                      String peerPhone = GoogleSheetService.normalizePhone(
                        convo['PeerPhone'] ?? convo['peerPhone'] ?? '',
                      );
                      String lastMsg = convo['LastMessage'] ?? convo['lastMessage'] ?? '';
                      String peerName = _resolveName(peerPhone);
                      int unreadCount = int.tryParse(convo['UnreadCount']?.toString() ?? '0') ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(peerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            lastMsg == '[Image]' ? '📷 ছবি পাঠানো হয়েছে' : (lastMsg.isEmpty ? 'মোবাইল: $peerPhone' : lastMsg),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                              color: unreadCount > 0 ? Colors.black : Colors.grey[700],
                            ),
                          ),
                          trailing: unreadCount > 0
                              ? CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    unreadCount.toString(),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  currentUserId: widget.myPhone,
                                  peerUserId: peerPhone,
                                  peerName: peerName,
                                ),
                              ),
                            ).then((_) => _loadInbox());
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

// ================= চ্যাট পেজ =================
class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String peerUserId;
  final String peerName;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.peerUserId,
    required this.peerName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _isRestricted = false;
  bool _hasError = false;
  String _errorMessage = '';
  final ImagePicker _picker = ImagePicker();

  String get _currentUserId =>
      GoogleSheetService.normalizePhone(widget.currentUserId);

  String get _peerUserId =>
      GoogleSheetService.normalizePhone(widget.peerUserId);

  final List<String> _badWords = [
    'বিকাশ নম্বর', 'নগদ নম্বর', 'রকেট নম্বর', 'বিকাশ করো', 'নগদ করো', 'বিকাশ', 'নগদ', 'রকেট', 'সেন্ড মানি', 
    'ক্যাশ আউট', 'টাকা পাঠাও', 'টাকা বিকাশ', 'bkash number', 'nagad number', 
    'rocket number', 'send money', 'cash out', 'advance payment', 'ব্লাডের দাম', 'রক্তের দাম',
    'বিয়া করবা', 'বিয়ে করবা', 'প্রেম করতে চাই', 'বিয়ে করবে', 'বিয়ে করবি', 'বিয়ে করবো', 'বিয়া করবো',
    'প্রেম করবা', 'প্রেম করবে', 'প্রেম করবি', 'প্রেম করবো', 'ভালোবাসবে', 'বিয়ে করবে কি', 
    'বেয়াদব', 'বেয়adপ', 'বাল-ছাল', 'বালছাল', 'চোদ', 'চুদ', 'চুতমারানি', 'জারজ', 
    'ফাজিল', 'ইডিয়েট', 'বদমাশ', 'madarchod', 'bhenchod', 'bastard', 'shit', 'fuck', 
    'asshole', 'bitch', 'idiot', 'slut', 'whore', 'মাগী', 'বাল', 'চুদি', 'বোকাচোদা', 'বাঞ্চত', 'শালী', 'মাদারচোদ', 'বেশ্যা', 'শালা'
  ];

  @override
  void initState() {
    super.initState();
    _markReadAndFetch();
  }

  Future<void> _markReadAndFetch() async {
    await GoogleSheetService.markMessagesRead(_currentUserId, _peerUserId);
    await _fetchMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  bool _containsBadWords(String message) {
    String lowerMsg = message.toLowerCase();
    for (String word in _badWords) {
      if (lowerMsg.contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final response = await http.get(
        Uri.parse(GoogleSheetService.url).replace(queryParameters: {
          'action': 'getMessages',
          'user1': _currentUserId,
          'user2': _peerUserId,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          if (mounted) {
            setState(() {
              _messages = decoded;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = (decoded is Map && decoded['message'] != null)
                  ? decoded['message'].toString()
                  : 'সার্ভার থেকে অপ্রত্যাশিত উত্তর এসেছে: ${response.body}';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'সার্ভার এরর (স্ট্যাটাস কোড: ${response.statusCode})';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'নেটওয়ার্ক বা ডেটা পার্স করতে সমস্যা হয়েছে: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _postToSheet(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(GoogleSheetService.url),
        body: json.encode(body),
      );
      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('মেসেজ পাঠাতে ব্যর্থ: সার্ভার এরর (স্ট্যাটাস কোড: ${response.statusCode})')),
          );
        }
        return false;
      }
      Map<String, dynamic>? result;
      try {
        result = json.decode(response.body);
      } catch (_) {
        result = null;
      }
      if (result != null && result['status'] == 'success') {
        return true;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('মেসেজ পাঠাতে ব্যর্থ: ${result?['message'] ?? response.body}')),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('মেসেজ পাঠাতে ব্যর্থ: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_isRestricted) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image == null) return;

    if (mounted) setState(() => _isSending = true);

    Uint8List imageBytes = await image.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    bool ok = await _postToSheet({
      "action": "sendMessage",
      "sender": _currentUserId,
      "receiver": _peerUserId,
      "message": "[Image]",
      "image": base64Image,
      "timestamp": DateTime.now().toIso8601String(),
    });

    if (ok) {
      await _fetchMessages();
    }
    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    if (_containsBadWords(messageText)) {
      setState(() {
        _isRestricted = true;
      });
      _messageController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("অশালীন ভাষা বা আর্থিক লেনদেন সংক্রান্ত শব্দ ব্যবহারের কারণে চ্যাটটি রেস্ট্রিক্ট করা হয়েছে।"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    bool ok = await _postToSheet({
      "action": "sendMessage",
      "sender": _currentUserId,
      "receiver": _peerUserId,
      "message": messageText,
      "image": "",
      "timestamp": DateTime.now().toIso8601String(),
    });

    if (ok) {
      _messageController.clear();
      await _fetchMessages();
    }
    if (mounted) setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
        backgroundColor: Colors.redAccent,
      ),
      body: _isRestricted
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, size: 70, color: Colors.red),
                    SizedBox(height: 15),
                    Text(
                      "নিয়ম ভঙ্গের কারণে এই কনভারসেশনটি রেস্ট্রিক্ট বা ব্লক করা হয়েছে। রক্তদান সম্পূর্ণ ফ্রি, তাই আর্থিক লেনদেন বা অশালীন আচরণ নিষিদ্ধ।",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _hasError
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
                                    const SizedBox(height: 12),
                                    Text(
                                      'মেসেজ লোড করা যায়নি:\n$_errorMessage',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.red, fontSize: 13),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: _fetchMessages,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('আবার চেষ্টা করুন'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              reverse: true,
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                var message = _messages[_messages.length - 1 - index];
                                bool isMe = GoogleSheetService.normalizePhone(
                                      message['Sender'].toString(),
                                    ) ==
                                    _currentUserId;
                                String msgText = message['Message'] ?? "";
                                String imgData = message['Image'] ?? "";

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.red[100] : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (imgData.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.memory(
                                                base64Decode(imgData),
                                                height: 150,
                                                width: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        if (msgText.isNotEmpty && msgText != "[Image]")
                                          Text(
                                            msgText,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                if (_isSending)
                  const LinearProgressIndicator(color: Colors.redAccent),
                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image, color: Colors.redAccent),
                        onPressed: _pickAndSendImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "মেসেজ লিখুন...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.redAccent),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ================= ডোনার সাইনআপ পেজ =================
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

    bool success = await GoogleSheetService.addDonor(
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
    setState(() => _isSaving = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সাইনআপ সফল হয়েছে!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সাইনআপ ব্যর্থ হয়েছে!')));
    }
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
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'নাম'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'ইমেইল'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'পাসওয়ার্ড'), validator: (v) => v!.length < 6 ? 'কমপক্ষে ৬ ডিজিট দিন' : null),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'ব্লাড গ্রুপ'),
                items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v!),
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'লিঙ্গ'),
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedGender = v!),
              ),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'ঠিকানা'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _totalDonationsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পূর্বে কতবার রক্ত দিয়েছেন?')),
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

// ================= ডোনার লগইন পেজ =================
class DonorLoginPage extends StatefulWidget {
  const DonorLoginPage({super.key});

  @override
  State<DonorLoginPage> createState() => _DonorLoginPageState();
}

class _DonorLoginPageState extends State<DonorLoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> donors = await GoogleSheetService.getDonors();
    String inputPhone = GoogleSheetService.normalizePhone(_phoneController.text.trim());

    var foundDonor = donors.firstWhere(
      (d) {
        String p = GoogleSheetService.normalizePhone(d['Phone'] ?? d['phone'] ?? d['Mobile'] ?? '');
        String pass = d['Password'] ?? d['password'] ?? '';
        return p == inputPhone && pass == _passwordController.text.trim();
      },
      orElse: () => {},
    );

    if (!mounted) return;

    if (foundDonor.isNotEmpty) {
      String foundPhone = foundDonor['Phone'] ?? foundDonor['phone'] ?? foundDonor['Mobile'] ?? '';
      await GoogleSheetService.updateOnlineStatus(foundPhone, 'Online');
      foundDonor['OnlineStatus'] = 'Online';
      await UserSession.saveLogin(foundDonor);
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('নম্বর অথবা পাসওয়ার্ড ভুল হয়েছে!')));
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
            TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর')),
            const SizedBox(height: 10),
            TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'পাসওয়ার্ড')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('লগইন করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= লিডারবোর্ড ও রক্তদানের হিস্টোরি পেজ =================
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> _donors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonors();
  }

  Future<void> _loadDonors() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> donors = await GoogleSheetService.getDonors();
    if (!mounted) return;
    setState(() {
      _donors = donors;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('লিডারবোর্ড ও রক্তদানের হিস্টোরি')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _donors.length,
              itemBuilder: (context, index) {
                var d = _donors[index];
                String name = d['Name'] ?? d['name'] ?? '';
                String blood = d['BloodGroup'] ?? d['bloodGroup'] ?? '';
                String photo = d['Photo'] ?? d['photo'] ?? '';
                String totalDonations = d['TotalDonations'] ?? d['totalDonations'] ?? '0';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: photo.isNotEmpty ? MemoryImage(base64Decode(photo)) : null,
                      child: photo.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    title: Text('$name ($blood)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('মোট রক্তদান: $totalDonations বার'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonorDetailsHistoryPage(donorData: d),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ================= ডোনার ডিটেইলস হিস্টোরি পেজ =================
class DonorDetailsHistoryPage extends StatelessWidget {
  final Map<String, dynamic> donorData;
  const DonorDetailsHistoryPage({super.key, required this.donorData});

  @override
  Widget build(BuildContext context) {
    String name = donorData['Name'] ?? donorData['name'] ?? '';
    String photo = donorData['Photo'] ?? donorData['photo'] ?? '';
    String blood = donorData['BloodGroup'] ?? donorData['bloodGroup'] ?? '';
    String phone = donorData['Phone'] ?? donorData['phone'] ?? '';
    String lastDonation = donorData['LastDonationDate'] ?? donorData['lastDonationDate'] ?? '';
    String totalDonations = donorData['TotalDonations'] ?? donorData['totalDonations'] ?? '0';

    return Scaffold(
      appBar: AppBar(title: Text('$name-এর হিস্টোরি')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: photo.isNotEmpty ? MemoryImage(base64Decode(photo)) : null,
              child: photo.isEmpty ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 15),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('ব্লাড গ্রুপ: $blood', style: const TextStyle(fontSize: 16, color: Colors.red)),
            Text('মোবাইল: $phone'),
            const Divider(height: 30),
            ListTile(
              title: const Text('মোট রক্তদান'),
              trailing: Text('$totalDonations বার', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: const Text('শেষ রক্তদানের তারিখ'),
              trailing: Text(lastDonation.isNotEmpty ? lastDonation : 'তথ্য নেই', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ডোনার প্রোফাইল পেজ =================
class DonorProfilePage extends StatefulWidget {
  final Map<String, dynamic> donorData;
  const DonorProfilePage({super.key, required this.donorData});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController;
  
  String _photoBase64 = '';
  final ImagePicker _picker = ImagePicker();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.donorData['Name'] ?? widget.donorData['name'] ?? '');
    _addressController = TextEditingController(text: widget.donorData['Address'] ?? widget.donorData['address'] ?? '');
    _passwordController = TextEditingController(text: widget.donorData['Password'] ?? widget.donorData['password'] ?? '');
    _photoBase64 = widget.donorData['Photo'] ?? widget.donorData['photo'] ?? '';
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        _photoBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isUpdating = true);
    String phoneVal = widget.donorData['Phone'] ?? widget.donorData['phone'] ?? widget.donorData['Mobile'] ?? '';
    String emailVal = widget.donorData['Email'] ?? widget.donorData['email'] ?? '';
    String bloodVal = widget.donorData['BloodGroup'] ?? widget.donorData['bloodGroup'] ?? 'A+';
    String genderVal = widget.donorData['Gender'] ?? widget.donorData['gender'] ?? 'পুরুষ';
    String totalDonationsVal = widget.donorData['TotalDonations'] ?? widget.donorData['totalDonations'] ?? '0';
    String lastDonationVal = widget.donorData['LastDonationDate'] ?? widget.donorData['lastDonationDate'] ?? '';

    bool success = await GoogleSheetService.updateDonor(
      name: _nameController.text.trim(),
      phone: phoneVal,
      email: emailVal,
      bloodGroup: bloodVal,
      gender: genderVal,
      address: _addressController.text.trim(),
      lastDonationDate: lastDonationVal,
      password: _passwordController.text.trim(),
      totalDonations: totalDonationsVal,
      photo: _photoBase64,
    );

    if (success) {
      Map<String, dynamic> updatedData = Map.from(widget.donorData);
      updatedData['Name'] = _nameController.text.trim();
      updatedData['Address'] = _addressController.text.trim();
      updatedData['Photo'] = _photoBase64;
      updatedData['Password'] = _passwordController.text.trim();
      updatedData['OnlineStatus'] = 'Online';
      await UserSession.saveLogin(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('প্রোফাইল সফলভাবে আপডেট হয়েছে।')));
    }
    if (!mounted) return;
    setState(() => _isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    String onlineStat = widget.donorData['OnlineStatus'] ?? widget.donorData['onlineStatus'] ?? 'Offline';
    bool isOnline = onlineStat == 'Online';
    String phoneVal = widget.donorData['Phone'] ?? widget.donorData['phone'] ?? widget.donorData['Mobile'] ?? '';
    String bloodVal = widget.donorData['BloodGroup'] ?? widget.donorData['bloodGroup'] ?? 'A+';
    
    int totalDonationsCount = int.tryParse(widget.donorData['TotalDonations']?.toString() ?? '0') ?? 0;
    int points = totalDonationsCount * 10;
    String badgeName = 'ব্রোঞ্জ ডোনার (Bronze)';
    Color badgeColor = Colors.brown;

    if (points >= 150) {
      badgeName = 'প্লাটিনাম ডোনার (Platinum)';
      badgeColor = Colors.purple;
    } else if (points >= 100) {
      badgeName = 'গোল্ড ডোনার (Gold)';
      badgeColor = Colors.amber.shade800;
    } else if (points >= 50) {
      badgeName = 'সিলভার ডোনার (Silver)';
      badgeColor = Colors.blueGrey;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ডোনার প্রোফাইল ও ব্যাজ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'লিডারবোর্ড',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardPage())),
          ),
          IconButton(
            icon: const Icon(Icons.forum_outlined),
            tooltip: 'ইনবক্স',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InboxPage(myPhone: phoneVal))),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'লগআউট',
            onPressed: () async {
              await UserSession.logout();
              if (!mounted) return;
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.red.shade100,
                    backgroundImage: _photoBase64.isNotEmpty
                        ? MemoryImage(base64Decode(_photoBase64))
                        : null,
                    child: _photoBase64.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.red)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('মোট পয়েন্ট', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('$points', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                    const ContainerSeparator(),
                    Column(
                      children: [
                        const Text('অর্জনকৃত ব্যাজ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Chip(
                          backgroundColor: badgeColor,
                          label: Text(badgeName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? 'অনলাইন' : 'অফলাইন',
                  style: TextStyle(
                    fontSize: 14,
                    color: isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text('ব্লাড গ্রুপ: $bloodVal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            Text('মোবাইল: $phoneVal', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 30),
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'নাম')),
            TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'ঠিকানা')),
            TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'পাসওয়ার্ড')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: _isUpdating ? const CircularProgressIndicator(color: Colors.white) : const Text('প্রোফাইল আপডেট করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerSeparator extends StatelessWidget {
  const ContainerSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.grey.shade400);
  }
}

// ================= এডমিন লগইন পেজ =================
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _adminLogin() async {
    if (_phoneController.text.isEmpty || _passController.text.isEmpty) return;
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> admins = await GoogleSheetService.getAdminCredentials();
    String inputPhone = GoogleSheetService.normalizePhone(_phoneController.text.trim());

    var validAdmin = admins.firstWhere(
      (a) {
        String p = GoogleSheetService.normalizePhone(a['Phone'] ?? a['phone'] ?? a['Email'] ?? '');
        String pass = a['Password'] ?? a['password'] ?? '';
        return (p == inputPhone || a['Email'] == _phoneController.text.trim()) && (pass == _passController.text.trim());
      },
      orElse: () => {},
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (validAdmin.isNotEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ভুল ফোন/ইমেইল বা পাসওয়ার্ড!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('এডমিন লগইন')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('এডমিন প্যানেলে প্রবেশ করতে আপনার ফোন বা ইমেইল এবং পাসওয়ার্ড দিন', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'ফোন নম্বর বা ইমেইল', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextFormField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'পাসওয়ার্ড', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _adminLogin,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size.fromHeight(50)),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('লগইন করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= এডমিন ড্যাশবোর্ড =================
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _donors = [];
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  
  String? _selectedFilterBloodGroup;
  final List<String> _bloodGroups = ['সকল গ্রুপ', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedFilterBloodGroup = 'সকল গ্রুপ';
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    var donors = await GoogleSheetService.getDonors();
    var requests = await GoogleSheetService.getBloodRequests();
    if (!mounted) return;
    setState(() {
      _donors = donors;
      _requests = requests;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredDonors = _donors.where((donor) {
      if (_selectedFilterBloodGroup == null || _selectedFilterBloodGroup == 'সকল গ্রুপ') {
        return true;
      }
      String bloodStr = donor['BloodGroup'] ?? donor['bloodGroup'] ?? '';
      return bloodStr.trim().toUpperCase() == _selectedFilterBloodGroup!.trim().toUpperCase();
    }).toList();

    // যে সকল আবেদনের স্ট্যাটাস 'Accepted' বা ডোনার সাবমিট করা হয়েছে কিন্তু এখনো 'Approved' হয়নি
    final pendingApprovals = _requests.where((req) {
      String status = (req['Status'] ?? req['status'] ?? '').toString().trim();
      String donorPhone = (req['DonorPhone'] ?? req['donorPhone'] ?? '').toString().trim();
      return status == 'Accepted' || (status != 'Approved' && donorPhone.isNotEmpty);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('এডমিন ড্যাশবোর্ড'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'সকল ডোনার'),
            Tab(text: 'সকল পোস্ট'),
            Tab(text: 'এপ্রুভাল রিকোয়েস্ট'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // ১. সকল ডোনার ট্যাব
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilterBloodGroup,
                        decoration: const InputDecoration(
                          labelText: 'ব্লাড গ্রুপ দিয়ে ফিল্টার করুন',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedFilterBloodGroup = val;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredDonors.isEmpty
                          ? const Center(child: Text('এই গ্রুপে কোনো ডোনার পাওয়া যায়নি'))
                          : ListView.builder(
                              itemCount: filteredDonors.length,
                              itemBuilder: (context, index) {
                                final donor = filteredDonors[index];
                                String nameStr = donor['Name'] ?? donor['name'] ?? '';
                                String bloodStr = donor['BloodGroup'] ?? donor['bloodGroup'] ?? '';
                                String phoneStr = donor['Phone'] ?? donor['phone'] ?? donor['Mobile'] ?? '';
                                String passStr = donor['Password'] ?? donor['password'] ?? '';
                                String addressStr = donor['Address'] ?? donor['address'] ?? '';
                                String onlineStat = donor['OnlineStatus'] ?? donor['onlineStatus'] ?? 'Offline';
                                bool isOnline = onlineStat == 'Online';

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: ListTile(
                                    leading: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isOnline ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    title: Text('$nameStr ($bloodStr)', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('মোবাইল: $phoneStr\nপাসওয়ার্ড: $passStr\nঠিকানা: $addressStr'),
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'এডিট করুন',
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => DonorProfilePage(donorData: donor)))
                                            .then((_) => _loadAdminData());
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                // ২. সকল পোস্ট ট্যাব
                ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    String pName = req['PatientName'] ?? req['patientName'] ?? '';
                    String bGroup = req['BloodGroup'] ?? req['bloodGroup'] ?? '';
                    String loc = req['Location'] ?? req['location'] ?? '';
                    String ph = req['Phone'] ?? req['phone'] ?? '';
                    String donorAccepted = req['DonorName'] ?? req['donorName'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text('রোগী: $pName ($bGroup)', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('স্থান: $loc\nমোবাইল: $ph\nডোনার এক্সেপ্ট: ${donorAccepted.isEmpty ? "কেউ করেনি" : donorAccepted}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'ডিলিট করুন',
                          onPressed: () async {
                            bool success = await GoogleSheetService.deleteBloodRequest(pName, ph);
                            if (!mounted) return;
                            if (success) {
                              _loadAdminData();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পোস্ট সফলভাবে ডিলিট করা হয়েছে!')));
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                // ৩. এপ্রুভাল রিকোয়েস্ট ট্যাব (নতুন যোগ করা হয়েছে)
                pendingApprovals.isEmpty
                    ? const Center(child: Text('কোনো পেন্ডিং এপ্রুভাল রিকোয়েস্ট নেই'))
                    : ListView.builder(
                        itemCount: pendingApprovals.length,
                        itemBuilder: (context, index) {
                          final req = pendingApprovals[index];
                          String reqId = req['Id'] ?? req['id'] ?? req['PatientName'] ?? '';
                          String pName = req['PatientName'] ?? req['patientName'] ?? '';
                          String bGroup = req['BloodGroup'] ?? req['bloodGroup'] ?? '';
                          String donorName = req['DonorName'] ?? req['donorName'] ?? 'অজানা ডোনার';
                          String donorPhone = req['DonorPhone'] ?? req['donorPhone'] ?? '';
                          String donationDate = req['DonationDate'] ?? req['donationDate'] ?? '';
                          String bags = req['Bags'] ?? req['bags'] ?? '1';
                          String rating = req['Rating'] ?? req['rating'] ?? '5';
                          String comment = req['Comment'] ?? req['comment'] ?? '';

                          return Card(
                            margin: const EdgeInsets.all(10),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('রোগী: $pName ($bGroup)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Divider(),
                                  Text('• রক্তদানকারী: $donorName'),
                                  Text('• ডোনার মোবাইল: $donorPhone'),
                                  Text('• রক্তদানের তারিখ: $donationDate'),
                                  Text('• রক্ত প্রদান করেছেন: $bags ব্যাগ'),
                                  Text('• রেটিং: $rating স্টার'),
                                  if (comment.isNotEmpty) Text('• মন্তব্য: $comment'),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      bool success = await GoogleSheetService.approveDonation(
                                        requestId: reqId,
                                        donorPhone: donorPhone,
                                        bags: bags,
                                        donationDate: donationDate,
                                      );
                                      if (!mounted) return;
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('রক্তদানের তথ্য সফলভাবে এপ্রুভ করা হয়েছে এবং পয়েন্ট যোগ করা হয়েছে!')),
                                        );
                                        _loadAdminData();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('এপ্রুভ করতে ব্যর্থ হয়েছে!')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    icon: const Icon(Icons.check_circle, color: Colors.white),
                                    label: const Text('Approve & Add Points', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }
}

// ================= রক্তের আবেদন পোস্ট পেজ =================
class AddRequestPage extends StatefulWidget {
  const AddRequestPage({super.key});

  @override
  State<AddRequestPage> createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _recipientAddressController = TextEditingController();
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
    
    bool success = await GoogleSheetService.addBloodRequest(
      patientName: _patientNameController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      problem: _problemController.text.trim(),
      location: _locationController.text.trim(),
      bags: _bagsController.text.trim(),
      neededDate: _dateController.text.trim(),
      phone: _phoneController.text.trim(),
      recipientName: _recipientNameController.text.trim(),
      recipientAddress: _recipientAddressController.text.trim(),
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'guest_poster_phone',
        GoogleSheetService.normalizePhone(_phoneController.text),
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, true);
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
              TextFormField(controller: _recipientNameController, decoration: const InputDecoration(labelText: 'সেবাগ্রহীতার নাম'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _recipientAddressController, decoration: const InputDecoration(labelText: 'সেবাগ্রহীতার ঠিকানা'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'সেবাগ্রহীতার মোবাইল নম্বর'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              const Divider(height: 30),
              TextFormField(controller: _patientNameController, decoration: const InputDecoration(labelText: 'রোগীর নাম'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'কোন গ্রুপের রক্ত দরকার?'),
                items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v!),
              ),
              TextFormField(controller: _problemController, decoration: const InputDecoration(labelText: 'রোগের ধরন'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'ব্লাড নেওয়ার স্থান'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _bagsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'কত ব্যাগ লাগবে?'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'ব্লাড কখন প্রয়োজন (yyyy-mm-dd)'), validator: (v) => v!.isEmpty ? 'লিখুন' : null),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitRequest,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('পোস্ট করুন', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= পরামর্শ ও যোগাযোগ পেজ =================
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
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('আপনার পরামর্শ সফলভাবে জমা হয়েছে!')),
        );
        Navigator.pop(context);
      } else {
        setState(() => _isSubmitting = false);
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'নাম', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'লিখুন' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'মোবাইল', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'লিখুন' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'পরামর্শ/মন্তব্য', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'লিখুন' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('জমা দিন', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= আমাদের সম্পর্কে পেজ =================
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String directName = 'এইচ এম মামুন';
    const String directPhone = '01638557040';
    const String devName = 'মোঃ মোস্তাফিজুর রহমান';
    const String devPhone = '01978953539';

    Future<void> makeCall(String number) async {
      final Uri launchUri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('আমাদের সম্পর্কে')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('রক্তকণা যুব সামাজিক সংগঠন', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 5),
            const Text('পিরোজপুর | নিবন্ধন নং: ২৫/২০২০', style: TextStyle(color: Colors.grey)),
            const Divider(height: 30),
            ListTile(
              title: const Text('সংগঠনের পরিচালক', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('$directName\nমোবাইল: $directPhone'),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () => makeCall(directPhone),
              ),
            ),
            ListTile(
              title: const Text('অ্যাপ প্রস্তুতকারী', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('$devName\nমোবাইল: $devPhone'),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () => makeCall(devPhone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}