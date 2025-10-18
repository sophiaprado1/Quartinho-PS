// editar_imovel_page.dart
// Página simples para editar os campos principais do imóvel

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
  late TextEditingController _tituloCtrl;
  late TextEditingController _descricaoCtrl;
  late TextEditingController _enderecoCtrl;
  late TextEditingController _precoCtrl;
  late TextEditingController _cidadeCtrl;
  late TextEditingController _estadoCtrl;
  late TextEditingController _cepCtrl;
  late TextEditingController _quartosCtrl;
  late TextEditingController _banheirosCtrl;
  late TextEditingController _areaCtrl;
  String _periodicidade = 'mensal';
  String _tipo = 'apartamento';
  bool _mobiliado = false;
  bool _aceitaPets = false;
  bool _internet = false;
  bool _estacionamento = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  final d = widget.dados;
  _tituloCtrl = TextEditingController(text: d['titulo']?.toString() ?? '');
  _descricaoCtrl = TextEditingController(text: d['descricao']?.toString() ?? '');
  _enderecoCtrl = TextEditingController(text: d['endereco']?.toString() ?? '');
  _cidadeCtrl = TextEditingController(text: d['cidade']?.toString() ?? '');
  _estadoCtrl = TextEditingController(text: d['estado']?.toString() ?? '');
  _cepCtrl = TextEditingController(text: d['cep']?.toString() ?? '');
  _quartosCtrl = TextEditingController(text: d['quartos']?.toString() ?? '');
  _banheirosCtrl = TextEditingController(text: d['banheiros']?.toString() ?? '');
  _areaCtrl = TextEditingController(text: d['area']?.toString() ?? '');
  _precoCtrl = TextEditingController(text: d['preco']?.toString() ?? '');
  _periodicidade = d['periodicidade']?.toString() ?? 'mensal';
  _tipo = d['tipo']?.toString() ?? 'apartamento';
  _mobiliado = d['mobiliado'] == true;
  _aceitaPets = d['aceita_pets'] == true;
  _internet = d['internet'] == true;
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
    _quartosCtrl.dispose();
    _banheirosCtrl.dispose();
    _areaCtrl.dispose();
    _precoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final token = await AuthService.getSavedToken();
      if (token == null) return;

      final id = widget.dados['id'];
      final url = Uri.parse('${backendHost}/propriedades/propriedades/$id/');
      final body = {
        'titulo': _tituloCtrl.text.trim(),
        'descricao': _descricaoCtrl.text.trim(),
        'tipo': _tipo,
        'preco': _precoCtrl.text.trim(),
        'endereco': _enderecoCtrl.text.trim(),
        'cidade': _cidadeCtrl.text.trim(),
        'estado': _estadoCtrl.text.trim(),
        'cep': _cepCtrl.text.trim(),
        'quartos': int.tryParse(_quartosCtrl.text) ?? null,
        'banheiros': int.tryParse(_banheirosCtrl.text) ?? null,
        'area': double.tryParse(_areaCtrl.text) ?? null,
        'mobiliado': _mobiliado,
        'aceita_pets': _aceitaPets,
        'internet': _internet,
        'estacionamento': _estacionamento,
        'periodicidade': _periodicidade,
      };

      final resp = await http.patch(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));

      if (resp.statusCode == 200) {
        final updated = jsonDecode(resp.body) as Map<String, dynamic>;
        if (mounted) Navigator.pop(context, updated);
      } else if (resp.statusCode == 401) {
        await AuthService.logout();
      } else {
        final msg = 'Falha ao atualizar imóvel: ${resp.statusCode} ${resp.body}';
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro na requisição')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar imóvel'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B1D28),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tituloCtrl,
              decoration: InputDecoration(labelText: 'Título', border: const OutlineInputBorder(), hintText: 'Ex: Kitnet aconchegante'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descricaoCtrl,
              maxLines: 4,
              decoration: InputDecoration(labelText: 'Descrição', border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _enderecoCtrl,
              decoration: InputDecoration(labelText: 'Endereço', border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cidadeCtrl,
                    decoration: InputDecoration(labelText: 'Cidade', border: const OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _estadoCtrl,
                    decoration: InputDecoration(labelText: 'Estado', border: const OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cepCtrl,
                    decoration: InputDecoration(labelText: 'CEP', border: const OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _precoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Preço', border: const OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _periodicidade,
                  items: const [
                    DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
                    DropdownMenuItem(value: 'anual', child: Text('Anual')),
                  ],
                  onChanged: (v) => setState(() => _periodicidade = v ?? 'mensal'),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quartosCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quartos', border: const OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _banheirosCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Banheiros', border: const OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _areaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Área (m²)', border: const OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Tipo:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _tipo,
                  items: const [
                    DropdownMenuItem(value: 'apartamento', child: Text('Apartamento')),
                    DropdownMenuItem(value: 'casa', child: Text('Casa')),
                    DropdownMenuItem(value: 'kitnet', child: Text('Kitnet')),
                  ],
                  onChanged: (v) => setState(() => _tipo = v ?? 'apartamento'),
                ),
                const Spacer(),
                Checkbox(
                  value: _mobiliado,
                  onChanged: (v) => setState(() => _mobiliado = v ?? false),
                ),
                const Text('Mobiliado'),
              ],
            ),
            Row(
              children: [
                Checkbox(value: _aceitaPets, onChanged: (v) => setState(() => _aceitaPets = v ?? false)),
                const Text('Aceita pets'),
                const SizedBox(width: 12),
                Checkbox(value: _internet, onChanged: (v) => setState(() => _internet = v ?? false)),
                const Text('Internet'),
                const SizedBox(width: 12),
                Checkbox(value: _estacionamento, onChanged: (v) => setState(() => _estacionamento = v ?? false)),
                const Text('Estacionamento'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : const Text('Salvar alterações'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
