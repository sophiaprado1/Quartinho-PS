import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/constants.dart';
import '../../services/chat_service.dart';
import '../chat/chat_detail.dart';

class NotificacoesMensagensPage extends StatefulWidget {
  /// Se fornecido, ao abrir a tela vamos tentar focar/abrir essa conversa.
  final int? initialOtherUserId;
  /// Nome pré-carregado do outro usuário (ex: dono do imóvel) quando viemos de um fluxo externo.
  final String? initialOtherName;
  /// Foto pré-carregada do outro usuário (URL absoluta) quando viemos de um fluxo externo.
  final String? initialOtherPhoto;

  const NotificacoesMensagensPage({
    super.key,
    this.initialOtherUserId,
    this.initialOtherName,
    this.initialOtherPhoto,
  });

  @override
  State<NotificacoesMensagensPage> createState() => _NotificacoesMensagensPageState();
}

class _NotificacoesMensagensPageState extends State<NotificacoesMensagensPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_NotificacoesTabState> _notificacoesKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Atualiza o botão quando a aba muda
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se veio de um imóvel com initialOtherUserId, já começar na aba "Mensagens".
    // Só fazemos isso na primeira build para não "prender" o usuário na conversa
    // depois que ele voltar para esta tela.
    if (widget.initialOtherUserId != null && _tabController.index != 1 && !_tabController.indexIsChanging) {
      _tabController.index = 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Excluir todas',
              onPressed: _deleteAllNotifications,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container
              (
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EFFA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: FractionallySizedBox(
                  // pílula roxa ocupa ~88% da largura do container claro
                  widthFactor: 0.88,
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF6E56CF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // faz o indicador ocupar todo o espaço disponível (entre o primeiro e o último tab)
                    indicatorSize: TabBarIndicatorSize.tab,
                    // padding pequeno: a largura já vem da FractionallySizedBox
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF6E56CF),
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    tabs: const [
                      Tab(text: 'Notificações'),
                      Tab(text: 'Mensagens'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotificacoesTab(key: _notificacoesKey),
          _MensagensTab(
            initialOtherUserId: widget.initialOtherUserId,
            initialOtherName: widget.initialOtherName,
            initialOtherPhoto: widget.initialOtherPhoto,
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllNotifications() async {
    final token = await AuthService.getSavedToken();
    if (token == null) return;

    // Confirmação antes de excluir
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir todas', style: GoogleFonts.poppins()),
        content: Text(
          'Tem certeza que deseja excluir todas as notificações?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await NotificationService.deleteAllNotifications(token: token);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as notificações foram excluídas'),
          duration: Duration(seconds: 2),
        ),
      );
      // Recarrega a aba de notificações
      _notificacoesKey.currentState?._loadData();
    }
  }
}

class _NotificacoesTab extends StatefulWidget {
  const _NotificacoesTab({Key? key}) : super(key: key);

  @override
  State<_NotificacoesTab> createState() => _NotificacoesTabState();
}

class _NotificacoesTabState extends State<_NotificacoesTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _notificacoes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final token = await AuthService.getSavedToken();
    if (token == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      await NotificationService.markAllAsRead(token: token);
      final res = await NotificationService.listNotifications(token: token);
      if (mounted) {
        setState(() {
          _notificacoes = res ?? [];
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _formatarData(String dataIso) {
    try {
      final data = DateTime.parse(dataIso).toLocal();
      final agora = DateTime.now();
      final diferenca = agora.difference(data);
      if (diferenca.inDays > 1) {
        return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${(data.year % 100).toString().padLeft(2, '0')} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
      } else if (diferenca.inDays == 1 || diferenca.inHours > 20) {
        return 'Ontem às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
      } else if (diferenca.inHours >= 1) {
        return 'Há ${diferenca.inHours}h';
      } else if (diferenca.inMinutes >= 1) {
        return 'Há ${diferenca.inMinutes}m';
      } else {
        return 'Agora mesmo';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notificacoes.isEmpty) {
      return Center(
        child: Text('Nenhuma notificação ainda', style: GoogleFonts.poppins()),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _notificacoes.length,
        itemBuilder: (context, index) {
          final notificacao = _notificacoes[index];
          final bool lida = notificacao['lida'] ?? false;
          final String mensagem = notificacao['mensagem'] ?? '...';
          final String data = _formatarData(notificacao['data_criacao'] ?? '');
          final int notificationId = notificacao['id'] ?? 0;
          
          return Dismissible(
            key: Key('notif_$notificationId'),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              // Confirmação antes de excluir
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Excluir notificação', style: GoogleFonts.poppins()),
                  content: Text(
                    'Deseja excluir esta notificação?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancelar', style: GoogleFonts.poppins()),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              if (confirm != true) return false;
              
              // Deleta no backend
              final token = await AuthService.getSavedToken();
              if (token != null) {
                final ok = await NotificationService.deleteNotification(
                  token: token,
                  notificationId: notificationId,
                );
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificação excluída'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                return ok; // Remove da lista apenas se deletou no backend
              }
              return false;
            },
            onDismissed: (direction) {
              // Remove da lista local
              setState(() {
                _notificacoes.removeWhere((n) => n['id'] == notificationId);
              });
            },
            child: Card(
              elevation: 4,
              shadowColor: const Color(0xFF000000).withOpacity(0.05),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    lida ? Icons.notifications_outlined : Icons.notifications,
                    color: lida ? Colors.grey : Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  mensagem,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: lida ? FontWeight.normal : FontWeight.w600,
                    color: lida ? Colors.grey[600] : Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    data,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                  ),
                ),
                onTap: () async {
                  // Futuro: navegar para destino (imóvel/chat) conforme payload
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MensagensTab extends StatefulWidget {
  final int? initialOtherUserId;
  final String? initialOtherName;
  final String? initialOtherPhoto;

  const _MensagensTab({
    this.initialOtherUserId,
    this.initialOtherName,
    this.initialOtherPhoto,
  });

  @override
  State<_MensagensTab> createState() => _MensagensTabState();
}

class _MensagensTabState extends State<_MensagensTab> {
  bool _loading = true;
  String? _token;
  late ChatService _chatService;
  List<dynamic> _conversations = [];
  String _query = '';
  int? _myUserId;
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Quando esta página volta ao topo (após sair do chat), garantir refresh único.
    if (_didInitialLoad) {
      // Pequeno debounce para evitar dupla chamada.
      Future.microtask(() => _refreshConversations());
    }
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    final token = await AuthService.getSavedToken();
    if (token == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    _token = token;
    _chatService = ChatService(baseUrl: backendHost);
    
    // Resolve my user ID
    try {
      final me = await AuthService.me(token: token);
      if (me != null) {
        _myUserId = me['id'] is int ? me['id'] as int : int.tryParse(me['id']?.toString() ?? '');
      }
    } catch (_) {}
    
    try {
      final data = await _chatService.fetchConversations(token);
      if (!mounted) return;

      // Atualiza conversas. Não abrimos mais o chat automaticamente aqui;
      // o usuário sempre escolhe a conversa tocando na lista.
      setState(() => _conversations = data);
      _didInitialLoad = true;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refreshConversations() async {
    if (_token == null) return;
    try {
      final data = await _chatService.fetchConversations(_token!);
      if (!mounted) return;
      setState(() => _conversations = data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Exibe um loading melhorzinho enquanto carrega as conversas
      return const Center(child: CircularProgressIndicator());
    }
    // Não removemos mais conversas marcadas como deleted pelo backend;
    // isso é apenas um estado para histórico, e a conversa pode voltar a ter mensagens novas.
    final baseList = _conversations;

    // Aplica filtro de busca pelo nome do outro participante
    final filtered = _query.isEmpty
        ? baseList
        : baseList.where((c) {
            final parts = (c['participants'] as List<dynamic>? ?? []);
            // Encontrar o OUTRO participante (não eu)
            final other = parts.firstWhere(
              (p) {
                final participantId = p['id'] is int
                    ? p['id'] as int
                    : int.tryParse('${p['id']}');
                return participantId != _myUserId;
              },
              orElse: () => parts.isNotEmpty ? parts.first : null,
            );
            final name = other != null
                ? (other['nome'] ??
                    other['nome_completo'] ??
                    other['username'] ??
                    other['email']?.toString().split('@')[0] ??
                    '')
                : '';
            return name.toString().toLowerCase().contains(_query.toLowerCase());
          }).toList();

    if (filtered.isEmpty) {
      return Center(child: Text('Você ainda não tem mensagens', style: GoogleFonts.poppins()));
    }
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshConversations();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filtered.length + 2,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (ctx, i) {
          // Header with title and search
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('Todas as conversas', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            );
          }
          if (i == 1) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF4F6FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            );
          }
          final conv = filtered[i - 2];
          final participants = (conv['participants'] as List<dynamic>? ?? []);
          
          // Encontrar o OUTRO participante (não eu)
          final other = participants.firstWhere(
            (p) {
              final participantId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}');
              return participantId != _myUserId;
            },
            orElse: () => participants.isNotEmpty ? participants.first : null,
          );
          
          print('DEBUG - Participant data: $other');
          
          final otherName = other != null 
              ? (other['nome'] ?? other['nome_completo'] ?? other['username'] ?? other['email']?.toString().split('@')[0] ?? 'Usuário') 
              : 'Usuário';
          final otherId = other != null ? (other['id'] as int? ?? 0) : 0;
          
          // Construir URL completa da foto
          String? otherPhoto;
          if (other != null) {
            final photoPath = other['foto_perfil'] ?? other['avatar'];
            if (photoPath != null && photoPath.toString().isNotEmpty) {
              final photoStr = photoPath.toString();
              // Se já é URL completa, usa direto
              if (photoStr.startsWith('http')) {
                otherPhoto = photoStr;
              } else if (photoStr.startsWith('/media/')) {
                // Se começa com /media/, adiciona o backendHost
                otherPhoto = '$backendHost$photoStr';
              } else {
                // Se é caminho relativo sem /media/, constrói URL completa
                otherPhoto = '$backendHost/media/$photoStr';
              }
              print('DEBUG - Photo URL: $otherPhoto');
            }
          }
          
          final lastMessage = conv['last_message'] ?? '';
          final unread = (conv['unread'] ?? conv['unseen_count'] ?? 0) as int;
          final lastAt = conv['last_message_created'] ?? conv['updated_at'] ?? '';

          String timeLabel = '';
          try {
            if (lastAt is String && lastAt.isNotEmpty) {
              final dt = DateTime.parse(lastAt).toLocal();
              timeLabel = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            }
          } catch (_) {}

          return Dismissible(
            key: ValueKey('conv_$otherId' '_' '$i'),
            background: Container(
              color: Colors.orangeAccent,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Row(children: [Icon(Icons.volume_off, color: Colors.white), SizedBox(width: 8), Text('Silenciar', style: TextStyle(color: Colors.white))]),
            ),
            secondaryBackground: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.delete_outline, color: Colors.white), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.white))]),
            ),
            confirmDismiss: (direction) async {
              if (_token == null) return false;
              final convId = conv['id'] as int?;
              if (convId == null) return false;
              if (direction == DismissDirection.startToEnd) {
                // Silenciar/des-silenciar
                final currentMuted = (conv['muted'] ?? false) as bool;
                final ok = await _chatService.updateConversation(_token!, convId, muted: !currentMuted);
                if (ok) {
                  setState(() => conv['muted'] = !currentMuted);
                  // Feedback visual
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(!currentMuted ? 'Conversa silenciada' : 'Conversa reativada'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
                return false; // não remover da lista
              } else if (direction == DismissDirection.endToStart) {
                // Excluir
                final ok = await _chatService.updateConversation(_token!, convId, deleted: true);
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Conversa excluída'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                return ok; // remove da lista
              }
              return false;
            },
            onDismissed: (_) {
              setState(() => _conversations.removeWhere((c) => c['id'] == conv['id']));
            },
            child: ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundImage: otherPhoto != null && otherPhoto.isNotEmpty
                  ? NetworkImage(otherPhoto)
                  : null,
              child: otherPhoto == null || otherPhoto.isEmpty
                  ? Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?')
                  : null,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    otherName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                if (timeLabel.isNotEmpty)
                  Text(timeLabel, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
                if ((conv['muted'] ?? false) == true)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.volume_off, size: 16, color: Colors.orangeAccent),
                  ),
                if (unread > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6E56CF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
              ],
            ),
            onTap: () {
              if (_token == null) return;
              print('Navegando para chat - otherName: "$otherName", otherId: $otherId');
              _openConversationWith(otherId,
                  presetName: otherName, presetPhoto: otherPhoto);
            },
          ));
        },
      ),
    );
  }

  void _openConversationWith(int otherUserId,
      {String? presetName, String? presetPhoto}) {
    if (_token == null || otherUserId == 0) return;
    // Procura na lista a conversa com esse usuário, para reaproveitar dados (nome/foto)
    final conv = _conversations.firstWhere(
      (c) {
        final parts = (c['participants'] as List<dynamic>? ?? []);
        return parts.any((p) {
          final pid = p['id'];
          final pidInt = pid is int ? pid : int.tryParse('$pid');
          return pidInt == otherUserId;
        });
      },
      orElse: () => null,
    );

    String otherName = presetName ?? 'Usuário';
    String? otherPhoto = presetPhoto;

    if (conv != null) {
      final parts = (conv['participants'] as List<dynamic>? ?? []);
      final other = parts.firstWhere(
        (p) {
          final pid = p['id'];
          final pidInt = pid is int ? pid : int.tryParse('$pid');
          return pidInt == otherUserId;
        },
        orElse: () => parts.isNotEmpty ? parts.first : null,
      );
      if (other != null) {
        otherName = (other['nome'] ?? other['nome_completo'] ?? other['username'] ??
                other['email']?.toString().split('@')[0] ??
                otherName)
            .toString();

        final photoPath = other['foto_perfil'] ?? other['avatar'];
        if (photoPath != null && photoPath.toString().isNotEmpty) {
          final photoStr = photoPath.toString();
          if (photoStr.startsWith('http')) {
            otherPhoto = photoStr;
          } else if (photoStr.startsWith('/media/')) {
            otherPhoto = '$backendHost$photoStr';
          } else {
            otherPhoto = '$backendHost/media/$photoStr';
          }
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            chatService: _chatService,
            token: _token!,
            otherUserId: otherUserId,
            otherName: otherName,
            otherPhoto: otherPhoto,
          ),
        ),
      );
    });
  }
}
