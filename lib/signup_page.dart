import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/adinn_background.png', fit: BoxFit.fill),
          Positioned(
            left: 25,
            right: 25,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  child: Stack(
                    children: [
                      InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 8.0,
                        child: Image.asset(
                          'assets/images/adinn_background.png',
                          height: 500,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      IgnorePointer(
                        child: Container(color: Colors.white.withOpacity(0.5)),
                      ),

                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Image.asset('assets/images/casagrand_logo.png'),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 25,
                                left: 25,
                                right: 25,
                                bottom: 25,
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(hintText: "Name"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 25,
                                right: 25,
                                bottom: 25,
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(hintText: "Phone"),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              width: 230,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFF7CC81),
                                ),
                                child: Text(
                                  "Continue",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
