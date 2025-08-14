import 'package:ecomm_app/UI/common/home_carousel.dart';
import 'package:ecomm_app/UI/screens/home/widgets/home_screen_helper_widgets.dart';
import 'package:ecomm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = TextEditingController();
  final User? user = supabase.auth.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: homeScreenDrawer(context),
        key: _scaffoldKey,
        body: Column(
          children: [
            TopBarFb4(
              title: 'Welcome back,',
              upperTitle: '${user!.userMetadata!['full_name'] ?? user!.email}',
              onTapMenu: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const SizedBox(height: 25),
            Expanded(child: CustomCarouselFB2()),
            const Spacer(),
            BottomNavBarFb3(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
