import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/services/api_service.dart';
import 'package:flutter_app/providers/auth_provider.dart';

class BookingsWidget extends ConsumerStatefulWidget {
  const BookingsWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingsWidget> createState() => _BookingsWidgetState();
}

class _BookingsWidgetState extends ConsumerState<BookingsWidget> {
  List<dynamic> bookings = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Vous devez être connecté pour voir vos réservations'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Réservations')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text('Aucune réservation trouvée'))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(booking['title'] ?? 'Réservation'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${booking['date'] ?? 'Non spécifiée'}'),
                            Text('Statut: ${booking['status'] ?? 'Inconnu'}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _cancelBooking(booking['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadBookings,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);

    try {
      // 🚀 Utilisation du service API avec token automatique
      final apiService = ref.read(apiServiceProvider);
      final fetchedBookings = await apiService.getUserBookings();

      setState(() {
        bookings = fetchedBookings;
      });
    } catch (e) {
      _showError('Erreur lors du chargement des réservations: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _cancelBooking(dynamic bookingId) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.delete('/bookings/$bookingId');

      if (response.statusCode == 200) {
        _showSuccess('Réservation annulée avec succès');
        _loadBookings(); // Recharger la liste
      } else {
        _showError('Erreur lors de l\'annulation');
      }
    } catch (e) {
      _showError('Erreur lors de l\'annulation: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
