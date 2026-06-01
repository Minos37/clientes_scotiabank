import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OperacionesScreen extends ConsumerWidget {
  const OperacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Fondo ligeramente más oscuro para resaltar las tarjetas
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text(
          'Operaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // Ocultar flecha de atrás porque es pestaña principal
      ),
      body: Column(
        children: [
          // Cabecera curva roja
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFED0006),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: const Text(
              '¿Qué te gustaría hacer hoy?',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Lista de operaciones agrupadas
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildOperationGroup('Transferencias', [
                  _buildOperationItem(context, Icons.swap_horiz, 'Realizar transferencias', 'Entre tus cuentas, a terceros y otros bancos', onTap: () {
                    context.push('/transferencias');
                  }),
                  _buildOperationItem(context, Icons.qr_code_scanner, 'Transferir con QR', 'Paga escaneando códigos QR de Plin o Niubiz', isLast: true),
                ]),
                
                const SizedBox(height: 24),
                
                _buildOperationGroup('Pagos y Recargas', [
                  _buildOperationItem(context, Icons.receipt_long, 'Pago de Servicios', 'Agua, luz, teléfono, colegios y más', onTap: () {
                    context.push('/pagos');
                  }),
                  _buildOperationItem(context, Icons.credit_score, 'Pago de Tarjetas', 'Paga tus tarjetas de crédito Scotiabank u otros'),
                  _buildOperationItem(context, Icons.phone_android, 'Recargas de Celular', 'Claro, Movistar, Entel y Bitel', isLast: true),
                ]),
                
                const SizedBox(height: 24),
                
                _buildOperationGroup('Cambio de Moneda', [
                  _buildOperationItem(context, Icons.currency_exchange, 'Cambio de Dólares', 'Compra y venta con tipo de cambio preferencial', onTap: () {
                    context.push('/cambio-divisas');
                  }, isLast: true),
                ]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Índice de "Operaciones"
        selectedItemColor: const Color(0xFFED0006),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            context.go('/home');
          } else if (index == 1) {
            context.go('/tarjetas');
          } else if (index == 3) {
            context.go('/mas');
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

  // Nuevo helper para agrupar en tarjetas (Cards) blancas con sombra
  Widget _buildOperationGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  // Diseño mejorado de cada opción interactiva
  Widget _buildOperationItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap, bool isLast = false}) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap ?? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('La función "$title" se implementará pronto.')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFED0006).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: const Color(0xFFED0006), size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 68, endIndent: 16, color: Colors.grey.shade100),
      ],
    );
  }
}