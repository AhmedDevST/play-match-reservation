import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with TickerProviderStateMixin {
  // Pour les animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Pour la recherche
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  
  // Exemple de données de conversations
  final List<Map<String, dynamic>> _chatList = [
    {
      'id': '1',
      'name': 'Mehdi Kaouki',
      'avatar': 'assets/images/avatar.png',
      'lastMessage': 'Tu es disponible pour jouer demain ?',
      'time': '10:30',
      'unread': 2,
      'isOnline': true,
    },
    {
      'id': '2',
      'name': 'Sara Lghoul',
      'avatar': 'assets/images/avatar.png',
      'lastMessage': 'Le terrain était excellent!',
      'time': 'Hier',
      'unread': 0,
      'isOnline': true,
    },
    {
      'id': '3',
      'name': 'Karim Benzema',
      'avatar': 'assets/images/avatar.png',
      'lastMessage': 'Merci pour l\'invitation',
      'time': 'Hier',
      'unread': 0,
      'isOnline': false,
    },
    {
      'id': '4',
      'name': 'Yassine Bounou',
      'avatar': 'assets/images/avatar.png',
      'lastMessage': 'On a réservé le terrain pour vendredi',
      'time': 'Lun',
      'unread': 1,
      'isOnline': false,
    },
    {
      'id': '5',
      'name': 'Hakim Ziyech',
      'avatar': 'assets/images/avatar.png',
      'lastMessage': 'À la prochaine!',
      'time': '24/05',
      'unread': 0,
      'isOnline': false,
    },
  ];
  
  // Liste filtrée pour la recherche
  List<Map<String, dynamic>> _filteredChats = [];

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
    
    // Initialisation de la liste filtrée
    _filteredChats = List.from(_chatList);
    
    // Écoute des changements dans le champ de recherche
    _searchController.addListener(_filterChats);
  }

  // Fonction pour filtrer les conversations selon la recherche
  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _isSearching = query.isNotEmpty;
      
      if (_isSearching) {
        _filteredChats = _chatList.where((chat) {
          return chat['name'].toLowerCase().contains(query);
        }).toList();
      } else {
        _filteredChats = List.from(_chatList);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Messages",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey.shade800),
            onPressed: () {
              // Filtrer les messages
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher une conversation...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: _buildChatList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Créer une nouvelle conversation
        },
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatList() {
    if (_filteredChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching ? "Aucune conversation trouvée" : "Aucune conversation",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSearching 
                ? "Essayez une autre recherche"
                : "Commencez à discuter avec vos amis",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredChats.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final chat = _filteredChats[index];
        return _buildChatItem(chat, index);
      },
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.1;
        final value = (_animationController.value - delay).clamp(0.0, 1.0);
        
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                onTap: () {
                  // Naviguer vers la page de conversation individuelle
                  Navigator.of(context).pushNamed('/chat_detail', arguments: chat);
                },
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                      child: Text(
                        chat['name'].substring(0, 1),
                        style: const TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (chat['isOnline'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2EE59D),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  chat['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    chat['lastMessage'],
                    style: TextStyle(
                      color: chat['unread'] > 0 ? Colors.grey.shade800 : Colors.grey.shade500,
                      fontWeight: chat['unread'] > 0 ? FontWeight.w500 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat['time'],
                      style: TextStyle(
                        color: chat['unread'] > 0 ? const Color(0xFF1E88E5) : Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (chat['unread'] > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E88E5),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          chat['unread'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 