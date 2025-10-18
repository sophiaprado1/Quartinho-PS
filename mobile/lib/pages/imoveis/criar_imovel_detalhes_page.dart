// criar_imovel_detalhes_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CriarImovelDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> dadosParciais;
  const CriarImovelDetalhesPage({super.key, required this.dadosParciais});

  @override
  State<CriarImovelDetalhesPage> createState() => _CriarImovelDetalhesPageState();
}

class _CriarImovelDetalhesPageState extends State<CriarImovelDetalhesPage> {
  static const Color _bgPage = Color(0xFFF3F4F7);
  static const Color _accent = Color(0xFFFF8A34);
  static const Color _purple = Color(0xFF6E56CF);
  static const Color _textDark = Color(0xFF1B1D28);

  final _precoCtrl = TextEditingController(text: 'R\$ 975,00');

  final _tagLivreCtrl = TextEditingController();
  final FocusNode _tagFocus = FocusNode();
  final List<String> _customTags = [];

  bool _mensal = true;

  int _qtdQuartos = 3;
  int _qtdBanheiros = 2;
  int _qtdVarandas = 2;

  final List<_TagItem> _tags = [
    _TagItem('Garagem'),
    _TagItem('Pet friendly'),
    _TagItem('Móveis'),
    _TagItem('Internet inclusa'),
    _TagItem('Próximo à faculdade e ônibus'),
    _TagItem('Mobília'),
    _TagItem('Aceita vistoria'),
  ];

  @override
  void dispose() {
    _precoCtrl.dispose();
    _tagLivreCtrl.dispose();
    _tagFocus.dispose();
    super.dispose();
  }

  void _addCustomTag() {
    final text = _tagLivreCtrl.text.trim();
    if (text.isEmpty) return;
    if (_customTags.contains(text)) {
      _tagLivreCtrl.clear();
      _tagFocus.requestFocus();
      return;
    }
    setState(() => _customTags.add(text));
    _tagLivreCtrl.clear();
    _tagFocus.requestFocus();
  }

  void _removeCustomTag(String value) {
    setState(() => _customTags.remove(value));
  }

  void _salvar() {
    final tagsSelecionadas =
        _tags.where((t) => t.selected).map((t) => t.label).toList()
          ..addAll(_customTags);

    final dados = {
      ...widget.dadosParciais,
      'preco': _precoCtrl.text.trim(),
      'periodicidade': _mensal ? 'mensal' : 'anual',
      'quartos': _qtdQuartos,
      'banheiros': _qtdBanheiros,
      'varandas': _qtdVarandas,
      'tags': tagsSelecionadas,
    };

    _showPublicado(dados);
  }

  void _showPublicado(Map<String, dynamic> dados) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: .10),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Coloque suas imagens reais no assets se quiser
                  Icon(Icons.house_rounded, size: 92, color: _purple.withValues(alpha: .60)),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.check, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Seu anúncio foi publicado!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Agora é com a gente!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withValues(alpha: .55),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(), // fecha o modal
                      child: Text('Editar', style: GoogleFonts.poppins()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Fecha o modal e devolve os DADOS para quem abriu ESTA tela
                        Navigator.of(context).pop();                 // fecha o bottom sheet
                        Navigator.of(context).pop(dados);            // fecha a página atual com resultado
                        // Quem chamou (Localização) está com 'await' e vai dar pop pra trás com o mesmo Map.
                      },
                      child: Text(
                        'Pronto',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: _bgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Adicionar listagem',
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Positioned(
                    right: -24,
                    top: -8,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: .18),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Text(
                    'Estamos quase lá! Adicione\nmais detalhes',
                    style: GoogleFonts.poppins(
                      color: _textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Text('Valor do aluguel', style: _label),
              const SizedBox(height: 8),
              _RoundedField(
                controller: _precoCtrl,
                hintText: 'R\$ 950,00',
                suffix: const Icon(Icons.attach_money_rounded),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ToggleChip(
                    text: 'Mensal',
                    selected: _mensal,
                    onTap: () => setState(() => _mensal = true),
                  ),
                  const SizedBox(width: 8),
                  _ToggleChip(
                    text: 'Anual',
                    selected: !_mensal,
                    onTap: () => setState(() => _mensal = false),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              Text('Características do imóvel', style: _label),
              const SizedBox(height: 10),
              _CounterTile(
                label: 'Quartos',
                value: _qtdQuartos,
                onAdd: () => setState(() => _qtdQuartos++),
                onRemove: () => setState(() => _qtdQuartos = (_qtdQuartos - 1).clamp(0, 99)),
              ),
              const SizedBox(height: 10),
              _CounterTile(
                label: 'Banheiros',
                value: _qtdBanheiros,
                onAdd: () => setState(() => _qtdBanheiros++),
                onRemove: () => setState(() => _qtdBanheiros = (_qtdBanheiros - 1).clamp(0, 99)),
              ),
              const SizedBox(height: 10),
              _CounterTile(
                label: 'Varandas',
                value: _qtdVarandas,
                onAdd: () => setState(() => _qtdVarandas++),
                onRemove: () => setState(() => _qtdVarandas = (_qtdVarandas - 1).clamp(0, 99)),
              ),
              const SizedBox(height: 22),

              Text('Tags adicionais', style: _label),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _RoundedTextField(
                      controller: _tagLivreCtrl,
                      hintText: 'Adicionar tag (ex.: Exclusivo para mulheres)',
                      focusNode: _tagFocus,
                      onSubmitted: (_) => _addCustomTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 46,
                    width: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _addCustomTag,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._tags.map((t) => _Pill(
                        text: t.label,
                        selected: t.selected,
                        onTap: () => setState(() => t.selected = !t.selected),
                      )),
                  ..._customTags.map(
                    (t) => _DeletablePill(
                      text: t,
                      onDelete: () => _removeCustomTag(t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _salvar,
                  child: Text(
                    'Salvar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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

  TextStyle get _label => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textDark,
      );
}

// ---------- helpers ----------
class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? suffix;

  const _RoundedField({
    required this.controller,
    required this.hintText,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.black.withValues(alpha: .45)),
        suffixIcon: suffix == null ? null : Padding(padding: const EdgeInsets.only(right: 12), child: suffix),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFFF5F4FA),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  const _RoundedTextField({
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: GoogleFonts.poppins(),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.black.withValues(alpha: .45)),
        filled: true,
        fillColor: const Color(0xFFF5F4FA),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6E56CF) : const Color(0xFFF0F1F5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6E56CF).withValues(alpha: .25),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : const Color(0xFF1B1D28),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CounterTile({
    required this.label,
    required this.value,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
          _RoundIcon(icon: Icons.remove, onTap: onRemove),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Text('$value', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          _RoundIcon(icon: Icons.add, onTap: onAdd),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _Pill({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6E56CF) : const Color(0xFFF0F1F5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6E56CF).withValues(alpha: .25),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : const Color(0xFF1B1D28),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DeletablePill extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;
  const _DeletablePill({required this.text, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1B1D28),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagItem {
  final String label;
  bool selected;
  _TagItem(this.label, {this.selected = false});
}