import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/rotas.dart';
import 'package:recipe_list/services/login_service.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final user = loginService.user;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const Text("Menu", style: TextStyle(fontSize: 28, color: Colors.white)),
            currentAccountPictureSize: const Size(100, 100),
            accountName: Text(user?.displayName ?? "Usuário"),
            accountEmail: Text(user?.email ?? ""),
            decoration: const BoxDecoration(color: Colors.lightBlue),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Sair"),
            onTap: () async {
              Navigator.pop(context);
              await loginService?.signOut();
              Navigator.pushReplacementNamed(context, Rotas.login);
            },
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}