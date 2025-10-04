import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/back_pill_button.dart';
import 'widgets/skip_pill.dart';
import 'widgets/map_card.dart';
import 'widgets/address_card.dart';

class LocationPage extends StatefulWidget {
  final String name;
  final String email;

  const LocationPage({
    super.key,
    required this.name,
    required this.email,
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
                  color: Colors.black54,
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

                    debugPrint("Endereço: ${_addressCtrl.text}");
                    // TODO: chamar próxima tela (provavelmente ExtraSignUpPage)
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