import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/input_widget.dart';
import '../components/styles.dart';
import '../components/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? nama;
  String? email;
  String? noHP;
  bool _obscureText = true;

  final TextEditingController _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference akunCollection = _db.collection('akun');

      final password = _password.text;
      await _auth.createUserWithEmailAndPassword(
          email: email!, password: password);

      final docId = akunCollection.doc().id;
      await akunCollection.doc(docId).set({
        'uid': _auth.currentUser!.uid,
        'nama': nama,
        'email': email,
        'noHP': noHP,
        'docId': docId,
        'role': 'user',
      });

      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text('Register', style: headerStyle(level: 1)),
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: const Text(
                        'Create your profile to start your journey',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              InputLayout(
                                'Nama',
                                TextFormField(
                                  onChanged: (String value) => setState(() {
                                    nama = value;
                                  }),
                                  validator: notEmptyValidator,
                                  decoration:
                                      customInputDecoration("Nama Lengkap"),
                                ),
                              ),
                              InputLayout(
                                'Email',
                                TextFormField(
                                  onChanged: (String value) => setState(() {
                                    email = value;
                                  }),
                                  validator: notEmptyValidator,
                                  decoration:
                                      customInputDecoration("email@email.com"),
                                ),
                              ),
                              InputLayout(
                                'No. Handphone',
                                TextFormField(
                                  onChanged: (String value) => setState(() {
                                    noHP = value;
                                  }),
                                  validator: notEmptyValidator,
                                  decoration:
                                      customInputDecoration("+62 80000000"),
                                ),
                              ),
                              InputLayout(
                                'Password',
                                TextFormField(
                                  controller: _password,
                                  validator: notEmptyValidator,
                                  obscureText: _obscureText,
                                  decoration: customInputDecoration(
                                    "",
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              InputLayout(
                                'Konfirmasi Password',
                                TextFormField(
                                  validator: (value) =>
                                      passConfirmationValidator(
                                          value, _password),
                                  obscureText: true,
                                  decoration: customInputDecoration(
                                    "",
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                width: double.infinity,
                                child: FilledButton(
                                    style: buttonStyle,
                                    child: Text('Register',
                                        style:
                                            headerStyle(level: 3, dark: false)),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        if (_formKey.currentState!.validate()) {
                                          register();
                                        }
                                      }
                                    }),
                              )
                            ],
                          )),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? '),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text('Login di sini',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
