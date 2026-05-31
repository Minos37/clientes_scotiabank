import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/tarjeta_viewmodel.dart';
import 'package:intl/intl.dart';

class TarjetasScreen extends ConsumerWidget {
  const TarjetasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarjetasAsync = ref.watch(tarjetasProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text(
          'Mis Tarjetas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: tarjetasAsync.when(
        data: (tarjetas) {
          if (tarjetas.isEmpty) {
            return const Center(
              child: Text(
                'No tienes tarjetas registradas.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tarjetas.length,
            itemBuilder: (context, index) {
              final tarjeta = tarjetas[index];
              final isCredito = tarjeta.tipo == 'credito';
              final logoImage = tarjeta.marca.toLowerCase() == 'visa'
                  ? 'Visa' // Podríamos usar assets si tuvieramos, pero usaremos texto por ahora
                  : tarjeta.marca;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCredito 
                        ? [const Color(0xFF1E1E1E), const Color(0xFF3A3A3A)] // Negro para crédito
                        : [const Color(0xFFED0006), const Color(0xFFB70005)], // Rojo para débito
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isCredito ? Colors.black26 : Colors.red.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isCredito ? 'Tarjeta de Crédito' : 'Tarjeta de Débito',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            logoImage,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tarjeta.numeroEnmascarado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Vencimiento', style: TextStyle(color: Colors.white54, fontSize: 10)),
                              Text(
                                DateFormat('MM/yy').format(tarjeta.fechaVencimiento),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                          if (isCredito && tarjeta.lineaCredito != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Línea de Crédito', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                Text(
                                  currencyFormatter.format(tarjeta.lineaCredito),
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          if (!isCredito && tarjeta.saldoDisponible != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Saldo Disponible', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                Text(
                                  currencyFormatter.format(tarjeta.saldoDisponible),
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // El índice 1 corresponde a "Tarjetas"
        selectedItemColor: const Color(0xFFED0006),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            context.go('/home');
          } else if (index == 2) {
            // Operaciones
          } else if (index == 3) {
            // Más
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Tarjetas'),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: 'Operaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Más'),
        ],
      ),
    );
  }
}
