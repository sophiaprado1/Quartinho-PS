import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/back_pill_button.dart';
import 'widgets/skip_pill.dart';
import 'widgets/map_card.dart';
import 'widgets/address_card.dart';

// importe sua ExtraSignUpPage real
import 'package:mobile/pages/signup/extra_signup_page.dart';

class LocationPage extends StatefulWidget {
  final String name;
  final String email;
  final String? cpf;
  final DateTime? birthDate;

  const LocationPage({
    super.key,
    required this.name,
    required this.email,
    this.cpf,
    this.birthDate,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

void _goNext() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ExtraSignUpPage(
        name: widget.name,
        email: widget.email,
        cpf: widget.cpf ?? '',
        birthDate: widget.birthDate ?? DateTime(2000, 1, 1),
        city: _addressCtrl.text.isNotEmpty ? _addressCtrl.text : null,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackPillButton(),
                  SkipPill(
                    name: widget.name,
                    email: widget.email,
                    cpf: widget.cpf ?? '',
                    birthDate: widget.birthDate ?? DateTime(2000, 1, 1),
                    onSkip: _goNext,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                "Local",
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Você pode mudar essa configuração depois",
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.55), // ✅ trocado
                ),
              ),
              const SizedBox(height: 20),

              const MapCard(),
              const SizedBox(height: 16),

              // Campo endereço
              AddressCard(controller: _addressCtrl),

              const Spacer(),

              // Botão próximo
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB268B4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (_addressCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Por favor, insira um endereço"),
                        ),
                      );
                      return;
                    }

                    // Se quiser salvar endereço/cidade, você pode passar adiante também.
                    _goNext();
                  },
                  child: Text(
                    "Próximo",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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