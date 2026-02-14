import 'package:flutter/material.dart';
import 'package:trip_admin/auth/auth.dart';
import 'package:trip_admin/home.dart';
import 'package:trip_admin/navigationbar/bottomnav.dart';
import 'package:trip_admin/signup.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _loginstate();
}

class _loginstate extends State<Login> {
  final _adminFormKey = GlobalKey<FormState>();

  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  

     

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                child: Image.network(
                  "https://images.unsplash.com/photo-1597407068889-782ba11fb621?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8ZGFyayUyMG1vdW50YWlufGVufDB8fDB8fHww&fm=jpg&q=60&w=3000",
                  fit: BoxFit.cover,
                ),
              ),
              Opacity(
                opacity: 0.7,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.brown,
                        const Color.fromARGB(255, 169, 128, 113),
                        const Color.fromARGB(255, 86, 168, 244),
                        const Color.fromARGB(255, 5, 123, 234),
                      ],
                    ),
                  ),
                  child: Form(
                    key: _adminFormKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 130),
                          child: Icon(
                            Icons.connecting_airports_outlined,
                            size: 90,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 82),
                          child: Row(
                            children: [
                              Text(
                                "Go",
                                style: TextStyle(
                                  fontSize: 70,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Travel",
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text("“Journey before destination.”"),
                        SizedBox(height: 37),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: TextFormField(
                            controller: _adminEmailController,
                            decoration: InputDecoration(
                              
                              prefixIcon: Icon(Icons.mail),
                              hintText: "User email",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              // ✅ Email pattern validation
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(value)) {
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: TextFormField(
                            controller:_adminPasswordController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: "Password",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              } else if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 100),
                        GestureDetector(
                          onTap: () async{

                            if (_adminFormKey.currentState!.validate()) {
                              await Authservice().login(
                                context: context,
                                email: _adminEmailController.text,
                                password: _adminPasswordController.text,
                              );
                             
                              
                            }
                            
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.amber,
                            ),
                            height: 45,
                            width: 190,

                            child: Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                       
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
