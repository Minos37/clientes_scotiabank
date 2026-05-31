import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/cuenta_viewmodel.dart';
import '../viewmodel/transaccion_viewmodel.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Formateador de moneda para que se vea como dinero real
  final currencyFormatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado del usuario actual
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    
    // Nombre a mostrar (usamos el nombre si existe, o la primera parte del correo)
    final displayName = user?.nombre ?? user?.email.split('@')[0] ?? 'Cliente';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006), // Rojo Scotiabank
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFFED0006)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hola,',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // TODO: Navegar a notificaciones
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              // Llamamos a la función logout, el router nos regresará al login automáticamente
              ref.read(authViewModelProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(context),
            const SizedBox(height: 24),
            _buildQuickAccessSection(context),
            const SizedBox(height: 24),
            _buildRecentMovementsSection(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFED0006),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
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

  // 1. Tarjeta de Saldo Total
  Widget _buildBalanceCard(BuildContext context) {
    final cuentasAsync = ref.watch(cuentasProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFED0006),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Total Disponible',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          cuentasAsync.when(
            data: (cuentas) {
              final totalSaldo = cuentas.fold<double>(
                  0.0, (sum, cuenta) => sum + cuenta.saldo);
              final cuentaPrincipal = cuentas.isNotEmpty ? cuentas.first.numeroCuenta : 'Sin cuenta';
              final ultimosDigitos = cuentaPrincipal.length > 4 
                  ? cuentaPrincipal.substring(cuentaPrincipal.length - 4) 
                  : cuentaPrincipal;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyFormatter.format(totalSaldo),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Cuenta •••• $ultimosDigitos',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const Spacer(),
                      Icon(Icons.visibility_off, color: Colors.white.withOpacity(0.8), size: 20),
                    ],
                  )
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (e, st) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Error al cargar saldo',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Sección de Accesos Rápidos
  Widget _buildQuickAccessSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accesos Rápidos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickAccessAction(Icons.send, 'Transferir'),
              _buildQuickAccessAction(Icons.receipt_long, 'Pagar\nServicios'),
              _buildQuickAccessAction(Icons.phone_android, 'Recargas'),
              _buildQuickAccessAction(Icons.currency_exchange, 'Cambiar\nDólares'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessAction(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFED0006), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // 3. Sección de Movimientos Recientes
  Widget _buildRecentMovementsSection(BuildContext context) {
    final transaccionesAsync = ref.watch(transaccionesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimos Movimientos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              TextButton(
                onPressed: () {
                  context.push('/movimientos');
                },
                child: const Text('Ver todos', style: TextStyle(color: Color(0xFFED0006))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: transaccionesAsync.when(
              data: (transacciones) {
                if (transacciones.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay movimientos recientes.'),
                  );
                }

                return Column(
                  children: transacciones.map((t) {
                    final isIncome = t.tipo == 'credito';
                    // Convertimos la fecha a algo más legible: "Hoy", "Ayer", o fecha
                    final now = DateTime.now();
                    final diff = now.difference(t.fecha).inDays;
                    String dateStr;
                    if (diff == 0 && now.day == t.fecha.day) {
                      dateStr = 'Hoy';
                    } else if (diff == 1 || (diff == 0 && now.day != t.fecha.day)) {
                      dateStr = 'Ayer';
                    } else {
                      dateStr = DateFormat('dd/MM/yyyy').format(t.fecha);
                    }

                    return Column(
                      children: [
                        _buildMovementTile(t.descripcion, dateStr, t.monto, isIncome: isIncome),
                        if (t != transacciones.last) const Divider(),
                      ],
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
              error: (e, st) => const Text('Error al cargar movimientos'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMovementTile(String title, String date, double amount, {bool isIncome = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${currencyFormatter.format(amount.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
