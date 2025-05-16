import 'package:flutter/material.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic>? chatData;
  
  const ChatDetailPage({Key? key, this.chatData}) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> with TickerProviderStateMixin {
  // Pour les animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Pour l'envoi de messages
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Exemple de données de messages
  List<Map<String, dynamic>> _messages = [];
  
  // Pour le statut de saisie
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
    
    // Charger les messages d'exemple selon l'interlocuteur
    _loadMessages();
  }

  void _loadMessages() {
    // Générer des données d'exemple basées sur l'identifiant de la conversation
    final chatId = widget.chatData?['id'] ?? '1';
    final otherName = widget.chatData?['name'] ?? 'Utilisateur';
    
    // Générer des exemples de messages
    setState(() {
      _messages = [
        {
          'id': '1',
          'text': 'Salut, comment ça va?',
          'isMe': true,
          'time': '10:00',
          'status': 'read',
        },
        {
          'id': '2',
          'text': 'Bonjour! Ça va bien et toi?',
          'isMe': false,
          'time': '10:02',
          'status': 'received',
        },
        {
          'id': '3',
          'text': 'Bien merci! Je me demandais si tu serais disponible pour jouer au football demain?',
          'isMe': true,
          'time': '10:05',
          'status': 'read',
        },
        {
          'id': '4',
          'text': 'Oui, bien sûr! Quelle heure préfères-tu?',
          'isMe': false,
          'time': '10:10',
          'status': 'received',
        },
        {
          'id': '5',
          'text': 'Parfait! Que penses-tu de 17h au terrain habituel?',
          'isMe': true,
          'time': '10:12',
          'status': 'read',
        },
        {
          'id': '6',
          'text': 'Ça me convient. J\'invite aussi quelques amis?',
          'isMe': false,
          'time': '10:15',
          'status': 'received',
        },
        {
          'id': '7',
          'text': 'Excellente idée! Plus on est de monde, plus c\'est amusant!',
          'isMe': true,
          'time': '10:18',
          'status': 'sent',
        },
      ];
    });
    
    // Faire défiler vers le bas pour afficher les messages les plus récents
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': _messageController.text.trim(),
      'isMe': true,
      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      'status': 'sending',
    };
    
    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
    
    // Faire défiler vers le bas pour montrer le nouveau message
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    // Simuler l'envoi du message (dans un backend réel, ce serait une API call)
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        final index = _messages.indexWhere((msg) => msg['id'] == newMessage['id']);
        if (index != -1) {
          _messages[index]['status'] = 'sent';
        }
      });
    });
    
    // Simuler la réception du message (dans un backend réel, ce serait un WebSocket)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        final index = _messages.indexWhere((msg) => msg['id'] == newMessage['id']);
        if (index != -1) {
          _messages[index]['status'] = 'delivered';
        }
      });
    });
    
    // Simuler la lecture du message
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        final index = _messages.indexWhere((msg) => msg['id'] == newMessage['id']);
        if (index != -1) {
          _messages[index]['status'] = 'read';
        }
      });
      
      // Simuler une réponse de l'interlocuteur
      _simulateReply();
    });
  }

  void _simulateReply() {
    // Simuler que l'interlocuteur tape
    setState(() {
      _isTyping = true;
    });
    
    // Après un certain délai, ajouter une réponse
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isTyping = false;
        
        final reply = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': 'D\'accord, à demain alors!',
          'isMe': false,
          'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          'status': 'received',
        };
        
        _messages.add(reply);
      });
      
      // Faire défiler vers le bas pour montrer le nouveau message
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatData = widget.chatData ?? {'name': 'Contact', 'isOnline': false};
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
              child: Text(
                chatData['name'].substring(0, 1),
                style: const TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatData['name'],
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  chatData['isOnline'] ? 'En ligne' : 'Hors ligne',
                  style: TextStyle(
                    color: chatData['isOnline'] ? const Color(0xFF2EE59D) : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: Colors.grey.shade800),
            onPressed: () {
              // Appeler le contact
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: Colors.grey.shade800),
            onPressed: () {
              // Appel vidéo
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    color: Colors.grey.shade50,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMe = message['isMe'] as bool;
                        
                        return _buildMessageItem(message, index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Indicateur de saisie
          if (_isTyping)
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildTypingDot(0, 0),
                        _buildTypingDot(1, 0.2),
                        _buildTypingDot(2, 0.4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${chatData['name']} est en train d\'écrire...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          
          // Zone de saisie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF1E88E5)),
                  onPressed: () {
                    // Ouvrir la sélection d'emojis
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF1E88E5)),
                  onPressed: () {
                    // Ajouter un fichier
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Votre message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E88E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index, double delay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final begin = 0.0;
        final end = 1.0;
        final animValue = Curves.easeInOut.transform(
          ((_animationController.value - delay) % 1.0).clamp(0.0, 1.0)
        );
        
        return Container(
          margin: EdgeInsets.only(left: index * 5.0),
          height: 8 + (4 * animValue),
          width: 8 + (4 * animValue),
          decoration: BoxDecoration(
            color: Color(0xFF1E88E5).withOpacity(0.6 + (0.4 * animValue)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    final isMe = message['isMe'] as bool;
    final prevIsSameUser = index > 0 && _messages[index - 1]['isMe'] == isMe;
    final nextIsSameUser = 
        index < _messages.length - 1 && _messages[index + 1]['isMe'] == isMe;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.05;
        final value = (_animationController.value - delay).clamp(0.0, 1.0);
        
        return Transform.translate(
          offset: Offset(isMe ? 20 * (1 - value) : -20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: EdgeInsets.only(
                top: prevIsSameUser ? 2 : 10,
                bottom: nextIsSameUser ? 2 : 10,
                left: isMe ? 50 : 0,
                right: isMe ? 0 : 50,
              ),
              child: Row(
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe && !prevIsSameUser)
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                      child: Text(
                        widget.chatData?['name'].substring(0, 1) ?? 'U',
                        style: const TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  
                  if (!isMe && prevIsSameUser)
                    const SizedBox(width: 32),
                  
                  const SizedBox(width: 8),
                  
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe 
                            ? const Color(0xFF1E88E5)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMe ? 18 : 0),
                          bottomRight: Radius.circular(isMe ? 0 : 18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['text'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.grey.shade800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                message['time'],
                                style: TextStyle(
                                  color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey.shade500,
                                  fontSize: 10,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 3),
                                _buildStatusIcon(message['status']),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color iconColor;
    
    switch (status) {
      case 'sending':
        iconData = Icons.access_time;
        iconColor = Colors.white.withOpacity(0.5);
        break;
      case 'sent':
        iconData = Icons.check;
        iconColor = Colors.white.withOpacity(0.7);
        break;
      case 'delivered':
        iconData = Icons.done_all;
        iconColor = Colors.white.withOpacity(0.7);
        break;
      case 'read':
        iconData = Icons.done_all;
        iconColor = const Color(0xFF2EE59D).withOpacity(0.9);
        break;
      default:
        iconData = Icons.check;
        iconColor = Colors.white.withOpacity(0.7);
    }
    
    return Icon(
      iconData,
      size: 14,
      color: iconColor,
    );
  }
} 