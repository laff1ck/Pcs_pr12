import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class ProfPage extends StatefulWidget {
  @override
  ProfPageState createState() => ProfPageState();
}

class ProfPageState extends State<ProfPage> {
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Пользователь не авторизован.');
      }

      print('Current User ID: ${user.id}');
      final response = await Supabase.instance.client
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        throw Exception('Пользователь не найден в базе данных.');
      }

      setState(() {
        _userName = response['name'] ?? 'Имя не указано';
        _userEmail = user.email;
      });
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );

      setState(() {
        _userName = 'Ошибка загрузки данных';
        _userEmail = '';
      });
    }
  }

  void _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Center(
        child: _userName != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Имя: $_userName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Почта: $_userEmail',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}