import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_list/rotas.dart';
import 'package:recipe_list/services/login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  LoginService? _loginService;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginService = Provider.of<LoginService>(context, listen: true);   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );
                      var ret = await _loginService!.login(_emailController.text, _passwordController.text);                      
                      Navigator.of(context).pop();
                      if (ret == null) {
                        Navigator.pushReplacementNamed(context, Rotas.recipes);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Login falhou - $ret"), 
                            duration: const Duration(seconds: 3)
                          ),
                        );
                      }
                    },
                    child: const Text("Entrar"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String? nome = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => const NomeInputBottomSheet(),
                      );

                      if (nome != null && nome.isNotEmpty) {

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        var ret = await _loginService!.signIn(
                          _emailController.text,
                          _passwordController.text,
                          nome,
                        );

                        Navigator.of(context).pop();

                        if (ret == null) {
                          Navigator.pushReplacementNamed(context, Rotas.recipes);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Login falhou - $ret"),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Cadastrar-se"),
                  ),
                ],
              ),
            ),
        ),
    );
  }
}

class NomeInputBottomSheet extends StatelessWidget {
  const NomeInputBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nomeController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Informe seu nome",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: "Nome",
            ),
            autofocus: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, nomeController.text.trim());
            },
            child: const Text("Confirmar"),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}