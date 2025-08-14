import 'package:ecomm_app/UI/screens/home/home_screen.dart';
import 'package:ecomm_app/UI/screens/profile/avatar.dart';
import 'package:ecomm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? user = supabase.auth.currentUser;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController deliveryAddressController =
      TextEditingController();

  @override
  void initState() {
    fullNameController.text = user?.userMetadata?['full_name'] ?? '';
    phoneNumberController.text = user?.userMetadata?['phone'] ?? '';
    emailController.text = user?.email ?? '';
    deliveryAddressController.text =
        user?.userMetadata?['delivery_address'] ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purpleAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user?.userMetadata?['avatar_url'] != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      user!.userMetadata!['avatar_url'],
                    ),
                  )
                else
                  Avatar(
                    imageUrl: user?.userMetadata?['avatar_url'],
                    onUpload: (imageUrl) {
                      setState(() {
                        user?.userMetadata?['avatar_url'] = imageUrl;
                      });
                    },
                  ),
                const SizedBox(height: 40),
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.person),
                    border: OutlineInputBorder(),
                    labelText: 'Full Name',
                    hintText:
                        user!.userMetadata!['full_name'] ??
                        'Enter your full name',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                    hintText:
                        user!.userMetadata!['phone'] ??
                        'Enter your phone number',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.email),
                    border: OutlineInputBorder(),
                    labelText: 'Email Address',
                    hintText: user!.email ?? 'Enter your email address',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: deliveryAddressController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                    labelText: 'Delivery Address',
                    hintText:
                        user!.userMetadata!['delivery_address'] ??
                        'Enter your full address',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    updateUserData(
                      context,
                      fullNameController.text.trim(),
                      phoneNumberController.text.trim(),
                      emailController.text.trim(),
                      deliveryAddressController.text.trim(),
                    );
                  },
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void updateUserData(
  BuildContext context,
  String fullName,
  String phoneNumber,
  String email,
  String deliveryAddress,
) async {
  final avatarUrl = supabase.auth.currentUser?.userMetadata?['avatar_url'];
  final UserResponse res = await supabase.auth.updateUser(
    UserAttributes(
      data: {
        'full_name': fullName,
        'phone': phoneNumber,
        'email': email,
        'delivery_address': deliveryAddress,
        'avatar_url': avatarUrl,
      },
    ),
  );
  final User? user = res.user;
  if (user != null) {
    // Also update avatar and other fields in the profiles table
    await supabase
        .from('profiles')
        .update({
          'full_name': fullName,
          'mobile_number': phoneNumber,
          'email_address': email,
          'delivery_address': deliveryAddress,
          'avatar_url': avatarUrl, // <-- add avatar here
        })
        .eq('id', user.id);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to update the user profile. Try again later.'),
      ),
    );
  }
}
