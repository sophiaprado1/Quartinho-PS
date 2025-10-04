import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/pages/location/location_page.dart';

class ChooseRolePage extends StatelessWidget {
  final String name;
  final String email;
  final String cpf;            // 👈 novo
  final DateTime birthDate;    // 👈 novo

  const ChooseRolePage({
    super.key,
    required this.name,
    required this.email,
    required this.cpf,         // 👈 novo
    required this.birthDate,   // 👈 novo
  });

  static const Color bgPage = Color(0xFFF3F4F7);
  static const Color accent = Color(0xFFFF8533);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: _BackPillButton(onTap: () => Navigator.pop(context)),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Escolha seu perfil",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Selecione como deseja utilizar o app",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              color: Colors.black.withValues(alpha: 0.55),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 56),

                          _RoleButton(
                            label: "Sou Locador",
                            icon: Icons.home_work_outlined,
                            onTap: () {
                              // TODO: fluxo do Locador (repassar os mesmos dados)
                            },
                          ),
                          const SizedBox(height: 20),

                          // 👉 Repassa name, email, cpf, birthDate
                          _RoleButton(
                            label: "Sou Inquilino",
                            icon: Icons.person_outline,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LocationPage(
                                    name: name,
                                    email: email,
                                    cpf: cpf,                 // 👈 novo
                                    birthDate: birthDate,     // 👈 novo
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _RoleButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ChooseRolePage.accent,
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackPillButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackPillButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Center(child: Icon(Icons.arrow_back_ios_new_rounded, size: 18)),
        ),
      ),
    );
  }
}