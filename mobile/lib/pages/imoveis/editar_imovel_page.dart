// editar_imovel_page.dart
// Layout modernizado, responsivo, sem overflow, e persistindo TODOS os campos.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../core/services/auth_service.dart';

class EditarImovelPage extends StatefulWidget {
  final Map<String, dynamic> dados;
  const EditarImovelPage({super.key, required this.dados});

  @override
  State<EditarImovelPage> createState() => _EditarImovelPageState();
}

class _EditarImovelPageState extends State<EditarImovelPage> {
  // Controllers
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _enderecoCtrl;
  late final TextEditingController _cidadeCtrl;
  late final TextEditingController _estadoCtrl;
  late final TextEditingController _cepCtrl;
  late final TextEditingController _precoCtrl;
  late final TextEditingController _quartosCtrl;
  late final TextEditingController _banheirosCtrl;
  late final TextEditingController _varandasCtrl;
  late final TextEditingController _areaCtrl;

  // Seletores
  String _periodicidade = 'mensal';
  String _tipo = 'apartamento';

  // Booleans
  bool _mobiliado = false;
  bool _aceitaPets = false;
  bool _internet = false;
  bool _estacionamento = false;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.dados;

    _tituloCtrl     = TextEditingController(text: d['titulo']?.toString() ?? '');
    _descricaoCtrl  = TextEditingController(text: d['descricao']?.toString() ?? '');
    _enderecoCtrl   = TextEditingController(text: d['endereco']?.toString() ?? '');
    _cidadeCtrl     = TextEditingController(text: d['cidade']?.toString() ?? '');
    _estadoCtrl     = TextEditingController(text: d['estado']?.toString() ?? '');
    _cepCtrl        = TextEditingController(text: d['cep']?.toString() ?? '');
    _precoCtrl      = TextEditingController(text: d['preco']?.toString() ?? d['preco_total']?.toString() ?? '');
    _quartosCtrl    = TextEditingController(text: d['quartos']?.toString() ?? '');
    _banheirosCtrl  = TextEditingController(text: d['banheiros']?.toString() ?? '');
    _varandasCtrl   = TextEditingController(text: d['varandas']?.toString() ?? '');
    _areaCtrl       = TextEditingController(text: d['area']?.toString() ?? '');

    _periodicidade  = d['periodicidade']?.toString() == 'anual' ? 'anual' : 'mensal';
    _tipo           = (d['tipo'] ?? 'apartamento').toString();

    _mobiliado      = d['mobiliado'] == true;
    _aceitaPets     = d['aceita_pets'] == true;
    _internet       = d['internet'] == true;
    _estacionamento = d['estacionamento'] == true;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _enderecoCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _cepCtrl.dispose();
    _precoCtrl.dispose();
    _quartosCtrl.dispose();
    _banheirosCtrl.dispose();
    _varandasCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  // ---------- helpers de parsing/limpeza ----------
  int? _parseInt(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  double? _parseDoubleBR(String s) {
    var t = s.trim();
    if (t.isEmpty) return null;
    t = t.replaceAll(RegExp(r'[^0-9,\.]'), '');
    if (t.contains(',') && t.contains('.')) {
      t = t.replaceAll('.', '').replaceAll(',', '.'); // 1.234,56 -> 1234.56
    } else if (t.contains(',')) {
      t = t.replaceAll(',', '.');
    }
    return double.tryParse(t);
  }

  Map<String, dynamic> _clean(Map<String, dynamic> body) {
    body.removeWhere((k, v) {
      if (v == null) return true;
      if (v is String && v.trim().isEmpty) return true;
      return false;
    });
    return body;
  }

  InputDecoration _dec(String label, {String? hint, IconData? icon}) => InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        isDense: true,
      );

  Widget _section({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(color: Color(0xFF6E56CF), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ]),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final token = await AuthService.getSavedToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sessão inválida. Faça login novamente.')),
          );
        }
        return;
      }

      final id = widget.dados['id'];
      final url = Uri.parse('$backendHost/propriedades/propriedades/$id/');

      final precoVal = _parseDoubleBR(_precoCtrl.text);

      final body = _clean({
        'titulo'        : _tituloCtrl.text,
        'descricao'     : _descricaoCtrl.text,
        'tipo'          : _tipo,
        'preco'         : precoVal?.toString(),
        'endereco'      : _enderecoCtrl.text,
        'cidade'        : _cidadeCtrl.text,
        'estado'        : _estadoCtrl.text,
        'cep'           : _cepCtrl.text,
        'quartos'       : _parseInt(_quartosCtrl.text),
        'banheiros'     : _parseInt(_banheirosCtrl.text),
        'varandas'      : _parseInt(_varandasCtrl.text),
        'area'          : _parseDoubleBR(_areaCtrl.text),
        'mobiliado'     : _mobiliado,
        'aceita_pets'   : _aceitaPets,
        'internet'      : _internet,
        'estacionamento': _estacionamento,
        'periodicidade' : _periodicidade, // 'mensal' | 'anual'
      });

      final resp = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200) {
        final updated = jsonDecode(resp.body) as Map<String, dynamic>;
        if (!mounted) return;
        Navigator.pop(context, updated);
      } else if (resp.statusCode == 401) {
        await AuthService.logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
        );
      } else {
        if (!mounted) return;
        final msg = 'Falha ao atualizar imóvel: ${resp.statusCode} ${resp.body}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro na requisição')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF3F4F7);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Editar imóvel'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B1D28),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            // Seção: Básico
            _section(
              title: 'Básico',
              children: [
                TextFormField(
                  controller: _tituloCtrl,
                  decoration: _dec('Título', hint: 'Ex: Kitnet aconchegante', icon: Icons.title),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descricaoCtrl,
                  maxLines: 4,
                  decoration: _dec('Descrição', hint: 'Detalhe o imóvel, regras, comodidades…', icon: Icons.notes),
                ),
              ],
            ),

            // Seção: Localização
            _section(
              title: 'Localização',
              children: [
                TextFormField(controller: _enderecoCtrl, decoration: _dec('Endereço', icon: Icons.home_outlined)),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth > 640;
                    final cidade = TextFormField(controller: _cidadeCtrl, decoration: _dec('Cidade', icon: Icons.location_city));
                    final estado = TextFormField(controller: _estadoCtrl, decoration: _dec('Estado', icon: Icons.map_outlined));
                    final cep    = TextFormField(controller: _cepCtrl,    decoration: _dec('CEP',    icon: Icons.local_post_office_outlined));

                    if (wide) {
                      return Row(children: [
                        Expanded(child: cidade),
                        const SizedBox(width: 10),
                        Expanded(child: estado),
                        const SizedBox(width: 10),
                        Expanded(child: cep),
                      ]);
                    }
                    return Column(children: [
                      cidade,
                      const SizedBox(height: 10),
                      estado,
                      const SizedBox(height: 10),
                      cep,
                    ]);
                  },
                ),
              ],
            ),

            // Seção: Valores  (⚠️ sem Expanded em Column)
            _section(
              title: 'Valores',
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth > 640;
                    final precoField = TextFormField(
                      controller: _precoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _dec('Preço', hint: 'Ex: 950,00', icon: Icons.attach_money),
                    );
                    final periodicidadeField = DropdownButtonFormField<String>(
                      value: _periodicidade,
                      decoration: _dec('Periodicidade', icon: Icons.calendar_month),
                      items: const [
                        DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
                        DropdownMenuItem(value: 'anual',  child: Text('Anual')),
                      ],
                      onChanged: (v) => setState(() => _periodicidade = v ?? 'mensal'),
                    );

                    if (wide) {
                      return Row(children: [
                        Expanded(child: precoField),
                        const SizedBox(width: 10),
                        Expanded(child: periodicidadeField),
                      ]);
                    }
                    // estreito: Column sem Expanded
                    return Column(children: [
                      precoField,
                      const SizedBox(height: 10),
                      periodicidadeField,
                    ]);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: _dec('Tipo', icon: Icons.apartment),
                  items: const [
                    DropdownMenuItem(value: 'apartamento', child: Text('Apartamento')),
                    DropdownMenuItem(value: 'casa',        child: Text('Casa')),
                    DropdownMenuItem(value: 'kitnet',      child: Text('Kitnet')),
                  ],
                  onChanged: (v) => setState(() => _tipo = v ?? 'apartamento'),
                ),
              ],
            ),

            // Seção: Dimensões
            _section(
              title: 'Dimensões',
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth > 900;
                    final mid  = c.maxWidth > 640 && c.maxWidth <= 900;

                    // campos puros (sem Expanded) para reuso
                    final quartos   = TextFormField(controller: _quartosCtrl,   keyboardType: TextInputType.number, decoration: _dec('Quartos',   icon: Icons.king_bed_outlined));
                    final banheiros = TextFormField(controller: _banheirosCtrl, keyboardType: TextInputType.number, decoration: _dec('Banheiros', icon: Icons.bathtub_outlined));
                    final varandas  = TextFormField(controller: _varandasCtrl,  keyboardType: TextInputType.number, decoration: _dec('Varandas',  icon: Icons.balcony_outlined));
                    final area      = TextFormField(controller: _areaCtrl,      keyboardType: TextInputType.number, decoration: _dec('Área (m²)', icon: Icons.square_foot));

                    if (wide) {
                      return Row(children: [
                        Expanded(child: quartos),
                        const SizedBox(width: 10),
                        Expanded(child: banheiros),
                        const SizedBox(width: 10),
                        Expanded(child: varandas),
                        const SizedBox(width: 10),
                        Expanded(child: area),
                      ]);
                    }
                    if (mid) {
                      return Column(
                        children: [
                          Row(children: [
                            Expanded(child: quartos),
                            const SizedBox(width: 10),
                            Expanded(child: banheiros),
                            const SizedBox(width: 10),
                            Expanded(child: varandas),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: area),
                          ]),
                        ],
                      );
                    }
                    // estreito: Column sem Expanded
                    return Column(children: [
                      quartos,
                      const SizedBox(height: 10),
                      banheiros,
                      const SizedBox(height: 10),
                      varandas,
                      const SizedBox(height: 10),
                      area,
                    ]);
                  },
                ),
              ],
            ),

            // Seção: Comodidades
            _section(
              title: 'Comodidades',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _BoolTile(
                      label: 'Mobiliado',
                      value: _mobiliado,
                      onChanged: (v) => setState(() => _mobiliado = v),
                      icon: Icons.chair_alt_outlined,
                    ),
                    _BoolTile(
                      label: 'Aceita pets',
                      value: _aceitaPets,
                      onChanged: (v) => setState(() => _aceitaPets = v),
                      icon: Icons.pets_outlined,
                    ),
                    _BoolTile(
                      label: 'Internet',
                      value: _internet,
                      onChanged: (v) => setState(() => _internet = v),
                      icon: Icons.wifi,
                    ),
                    _BoolTile(
                      label: 'Estacionamento',
                      value: _estacionamento,
                      onChanged: (v) => setState(() => _estacionamento = v),
                      icon: Icons.local_parking_outlined,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                        height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: Text(_loading ? 'Salvando…' : 'Salvar alterações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A34),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _loading ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoolTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  const _BoolTile({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: value,
      onSelected: (v) => onChanged(v),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      showCheckmark: true,
      shape: StadiumBorder(side: BorderSide(color: Theme.of(context).dividerColor)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}