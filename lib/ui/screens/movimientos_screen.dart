import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/transaccion_viewmodel.dart';
import 'package:intl/intl.dart';

class MovimientosScreen extends ConsumerWidget {
  const MovimientosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaccionesAsync = ref.watch(todasTransaccionesProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Un fondo ligeramente más claro
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text(
          'Movimientos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Abrir filtros
            },
          )
        ],
      ),
      body: transaccionesAsync.when(
        data: (transacciones) {
          if (transacciones.isEmpty) {
            return _buildEmptyState();
          }

          // Calcular ingresos y egresos
          double ingresos = 0;
          double egresos = 0;
          for (var t in transacciones) {
            if (t.tipo == 'credito') {
              ingresos += t.monto;
            } else {
              egresos += t.monto;
            }
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildSummarySection(ingresos, egresos, currencyFormatter),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Historial',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final t = transacciones[index];
                      return _buildTransactionCard(t, currencyFormatter);
                    },
                    childCount: transacciones.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Podemos dejarlo en 0 temporalmente, o crear un estado
        selectedItemColor: const Color(0xFFED0006),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            context.pop(); // Regresar al inicio
          } else if (index == 1) {
            context.push('/tarjetas');
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

  Widget _buildSummarySection(double ingresos, double egresos, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFED0006),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Ingresos',
              formatter.format(ingresos),
              Icons.arrow_downward,
              Colors.green.shade100,
              Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Gastos',
              formatter.format(egresos),
              Icons.arrow_upward,
              Colors.red.shade100,
              Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(dynamic t, NumberFormat formatter) {
    final isIncome = t.tipo == 'credito';
    final now = DateTime.now();
    final diff = now.difference(t.fecha).inDays;
    
    String dateStr;
    if (diff == 0 && now.day == t.fecha.day) {
      dateStr = 'Hoy • ${DateFormat('HH:mm').format(t.fecha)}';
    } else if (diff == 1 || (diff == 0 && now.day != t.fecha.day)) {
      dateStr = 'Ayer • ${DateFormat('HH:mm').format(t.fecha)}';
    } else {
      dateStr = DateFormat('dd MMM yyyy • HH:mm').format(t.fecha);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Ver detalle del movimiento
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
                    color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.descripcion,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${isIncome ? '+' : '-'}${formatter.format(t.monto.abs())}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isIncome ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Sin movimientos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            'Aún no tienes transacciones registradas.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
