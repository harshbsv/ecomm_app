import 'package:ecomm_app/UI/screens/home/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Sign In',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: SupaEmailAuth(
            redirectTo: kIsWeb ? null : 'io.mydomain.myapp://callback',
            onSignInComplete: (response) {
              print('**********Sign In Complete: ${response.user?.email}');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            onSignUpComplete: (response) {
              print('**********Sign Up Complete: ${response.user?.email}');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            metadataFields: [
              // Creates an additional TextField for string metadata, for example:
              // {'username': 'exampleUsername'}
              MetaDataField(
                prefixIcon: const Icon(Icons.person),
                label: 'Full Name',
                key: 'full_name',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter your Full Name.';
                  }
                  return null;
                },
              ),
              MetaDataField(
                prefixIcon: const Icon(Icons.person),
                label: 'Mobile Number',
                key: 'phone',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter your Mobile Number.';
                  }
                  return null;
                },
              ),
              // Creates a CheckboxListTile for boolean metadata, for example:
              // {'marketing_consent': true}
              BooleanMetaDataField(
                label: 'I wish to receive marketing emails',
                key: 'marketing_consent',
                checkboxPosition: ListTileControlAffinity.leading,
              ),
              // Supports interactive text. Fields can be marked as required, blocking form
              // submission unless the checkbox is checked.
              BooleanMetaDataField(
                key: 'terms_agreement',
                isRequired: true,
                checkboxPosition: ListTileControlAffinity.leading,
                richLabelSpans: [
                  const TextSpan(
                    text: 'I have read and agree to the ',
                    style: TextStyle(fontSize: 14),
                  ),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // do something, for example: navigate("terms_and_conditions");
                      },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
