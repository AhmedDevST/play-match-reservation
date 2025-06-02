import 'package:flutter/material.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  _NetworkPageState createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> with TickerProviderStateMixin {
  // Pour les onglets
  late TabController _tabController;
  
  // Pour les animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Exemple de données d'amis
  final List<Map<String, dynamic>> _friendsList = [
    {
      'name': 'Mehdi Kaouki',
      'avatar': 'assets/images/avatar.png',
      'status': 'En ligne',
      'isOnline': true,
      'lastSeen': '',
      'sports': ['Football', 'Basketball']
    },
    {
      'name': 'Karim Benzema',
      'avatar': 'assets/images/avatar.png',
      'status': 'Hors ligne',
      'isOnline': false,
      'lastSeen': 'Il y a 2h',
      'sports': ['Football']
    },
    {
      'name': 'Sara Lghoul',
      'avatar': 'assets/images/avatar.png',
      'status': 'En ligne',
      'isOnline': true,
      'lastSeen': '',
      'sports': ['Handball', 'Basketball']
    },
    {
      'name': 'Yassine Bounou',
      'avatar': 'assets/images/avatar.png',
      'status': 'Hors ligne',
      'isOnline': false,
      'lastSeen': 'Il y a 5h',
      'sports': ['Football']
    },
  ];
  
  // Exemple de suggestions d'amis
  final List<Map<String, dynamic>> _suggestedFriends = [
    {
      'name': 'Achraf Hakimi',
      'avatar': 'assets/images/avatar.png',
      'mutualFriends': 5,
      'sports': ['Football']
    },
    {
      'name': 'Soufiane Rahimi',
      'avatar': 'assets/images/avatar.png',
      'mutualFriends': 3,
      'sports': ['Football', 'Basketball']
    },
    {
      'name': 'Hakim Ziyech',
      'avatar': 'assets/images/avatar.png',
      'mutualFriends': 8,
      'sports': ['Football', 'Handball']
    },
    {
      'name': 'Fatima Zahra',
      'avatar': 'assets/images/avatar.png',
      'mutualFriends': 2,
      'sports': ['Basketball']
    },
  ];
  
  // Pour la recherche
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredFriends = [];
  List<Map<String, dynamic>> _filteredSuggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    
    // Initialisation du contrôleur d'onglets
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialisation de l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
    
    // Initialisation des listes filtrées
    _filteredFriends = List.from(_friendsList);
    _filteredSuggestions = List.from(_suggestedFriends);
    
    // Écoute des changements dans le champ de recherche
    _searchController.addListener(_filterLists);
  }

  // Fonction pour filtrer les listes selon la recherche
  void _filterLists() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _isSearching = query.isNotEmpty;
      
      if (_isSearching) {
        _filteredFriends = _friendsList.where((friend) {
          return friend['name'].toLowerCase().contains(query);
        }).toList();
        
        _filteredSuggestions = _suggestedFriends.where((friend) {
          return friend['name'].toLowerCase().contains(query);
        }).toList();
      } else {
        _filteredFriends = List.from(_friendsList);
        _filteredSuggestions = List.from(_suggestedFriends);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Réseau",
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
            icon: Icon(Icons.share, color: Colors.grey.shade800),
            onPressed: () {
              // Partager son profil
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher des amis...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              
              // Onglets
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1E88E5),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1E88E5),
                tabs: const [
                  Tab(text: "Mes amis"),
                  Tab(text: "Découvrir"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              color: Colors.grey.shade50,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Onglet "Mes amis"
                  _buildFriendsTab(),
                  
                  // Onglet "Découvrir"
                  _buildDiscoverTab(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ouvrir la boîte de dialogue pour ajouter un ami
          _showAddFriendDialog();
        },
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  // Onglet "Mes amis"
  Widget _buildFriendsTab() {
    if (_filteredFriends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching ? "Aucun ami trouvé" : "Vous n'avez pas encore d'amis",
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
                : "Commencez à ajouter des amis pour jouer ensemble",
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
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = _filteredFriends[index];
        return _buildFriendCard(friend);
      },
    );
  }

  // Carte d'ami
  Widget _buildFriendCard(Map<String, dynamic> friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: friend['isOnline'] ? const Color(0xFF2EE59D) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                child: Text(
                  friend['name'].substring(0, 1),
                  style: const TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            if (friend['isOnline'])
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 15,
                  height: 15,
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
          friend['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              friend['isOnline'] ? friend['status'] : friend['lastSeen'],
              style: TextStyle(
                color: friend['isOnline'] ? const Color(0xFF2EE59D) : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: (friend['sports'] as List<String>).map((sport) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    sport,
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.message, color: Color(0xFF1E88E5)),
              onPressed: () {
                // Ouvrir la conversation
              },
            ),
            IconButton(
              icon: const Icon(Icons.sports, color: Color(0xFF1E88E5)),
              onPressed: () {
                // Inviter à jouer
              },
            ),
          ],
        ),
      ),
    );
  }

  // Onglet "Découvrir"
  Widget _buildDiscoverTab() {
    if (_filteredSuggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "Aucune suggestion trouvée",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _isSearching 
                  ? "Essayez une autre recherche"
                  : "Nous n'avons pas de suggestions pour le moment",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section des suggestions basées sur les sports
        Text(
          "Suggestions basées sur vos sports préférés",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        
        // Liste des suggestions
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _filteredSuggestions[index];
            return _buildSuggestionCard(suggestion);
          },
        ),
      ],
    );
  }

  // Carte de suggestion d'ami
  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
            child: Text(
              suggestion['name'].substring(0, 1),
              style: const TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        title: Text(
          suggestion['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${suggestion['mutualFriends']} amis en commun",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: (suggestion['sports'] as List<String>).map((sport) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    sport,
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Ajouter l'ami
            _addFriend(suggestion);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            "Ajouter",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Fonction pour ajouter un ami
  void _addFriend(Map<String, dynamic> suggestion) {
    // Simuler l'ajout d'un ami
    setState(() {
      final newFriend = {
        'name': suggestion['name'],
        'avatar': 'assets/images/avatar.png', // Utiliser un placeholder générique
        'status': 'En ligne',
        'isOnline': true,
        'lastSeen': '',
        'sports': suggestion['sports'],
      };
      
      _friendsList.add(newFriend);
      _filteredFriends = List.from(_friendsList);
      
      // Retirer de la liste des suggestions
      _suggestedFriends.removeWhere((item) => item['name'] == suggestion['name']);
      _filteredSuggestions = List.from(_suggestedFriends);
    });
    
    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${suggestion['name']} a été ajouté à vos amis"),
        backgroundColor: const Color(0xFF2EE59D),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Boîte de dialogue pour ajouter un ami
  void _showAddFriendDialog() {
    final TextEditingController codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter un ami"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Entrez le code d'ami ou partagez le vôtre:",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: "Code d'ami",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person_add),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "MON-CODE-123",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFF1E88E5)),
                      onPressed: () {
                        // Copier le code
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Code copié dans le presse-papiers"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                // Vérifier le code d'ami
                if (codeController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  
                  // Simuler la recherche
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Recherche en cours..."),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
              ),
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }
}
