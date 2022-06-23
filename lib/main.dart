import 'package:flash_chat_flutter/components/protected_route.dart';
import 'package:flash_chat_flutter/screens/chats/list_chats_screen.dart';
import 'package:flash_chat_flutter/screens/forgot_password.dart';
import 'package:flash_chat_flutter/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/chats/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PartyChat());
}

class PartyChat extends StatelessWidget {
  const PartyChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      theme: ThemeData.light(),
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(
              chatId: ChatScreen.id,
              users: [],
            ),
        ForgotPasswordScreen.id: (context) => ForgotPasswordScreen(),
        ListChatsScreen.id: (context) => ProtectedRoute(
              screen: ListChatsScreen(),
            ),
        SettingsScreen.id: (context) => SettingsScreen()
      },
      builder: EasyLoading.init(),
    );
  }
}
