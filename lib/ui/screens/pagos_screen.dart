import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/cuenta_viewmodel.dart';
import '../viewmodel/tarjeta_viewmodel.dart';
import '../viewmodel/pago_servicio_viewmodel.dart';

class PagosScreen extends ConsumerStatefulWidget {
  const PagosScreen({super.key});

  @override
  ConsumerState<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends ConsumerState<PagosScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPaymentSheet(BuildContext context, String provider, String serviceType, {String? defaultContract}) {
    final contractController = TextEditingController(text: defaultContract ?? '');
    final amountController = TextEditingController(text: '45.00');
    String? selectedAccountId;
    String? selectedCardId;
    String paymentMethod = 'cuenta'; // 'cuenta' o 'tarjeta'

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer(
              builder: (context, ref, child) {
                final cuentasAsync = ref.watch(cuentasProvider);
                final tarjetasAsync = ref.watch(tarjetasProvider);
                final pagoState = ref.watch(pagoServicioViewModelProvider);

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  ),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    top: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pagar $provider',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        const Text('Método de Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Cuenta de Ahorros'),
                              selected: paymentMethod == 'cuenta',
                              selectedColor: const Color(0xFFED0006).withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: paymentMethod == 'cuenta' ? const Color(0xFFED0006) : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => paymentMethod = 'cuenta');
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: const Text('Tarjeta de Crédito'),
                              selected: paymentMethod == 'tarjeta',
                              selectedColor: const Color(0xFFED0006).withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: paymentMethod == 'tarjeta' ? const Color(0xFFED0006) : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => paymentMethod = 'tarjeta');
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Selector de Origen de Fondos
                        if (paymentMethod == 'cuenta') ...[
                          const Text('Seleccionar Cuenta de Origen', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          cuentasAsync.when(
                            data: (cuentas) {
                              if (cuentas.isEmpty) return const Text('No tienes cuentas disponibles');
                              selectedAccountId ??= cuentas.first.id;
                              return DropdownButtonFormField<String>(
                                value: selectedAccountId,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                                isExpanded: true,
                                items: cuentas.map((c) {
                                  final numCta = c.numeroCuenta;
                                  final ultimos = numCta.length > 4 ? numCta.substring(numCta.length - 4) : numCta;
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      'Cuenta ${c.tipo.toUpperCase()} •••• $ultimos (S/ ${c.saldo.toStringAsFixed(2)})',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => selectedAccountId = val),
                              );
                            },
                            loading: () => const LinearProgressIndicator(color: Color(0xFFED0006)),
                            error: (_, __) => const Text('Error al cargar cuentas'),
                          ),
                        ] else ...[
                          const Text('Seleccionar Tarjeta de Origen', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          tarjetasAsync.when(
                            data: (tarjetas) {
                              final creditoTarjetas = tarjetas.where((t) => t.tipo == 'credito').toList();
                              if (creditoTarjetas.isEmpty) return const Text('No tienes tarjetas de crédito disponibles');
                              selectedCardId ??= creditoTarjetas.first.id;
                              return DropdownButtonFormField<String>(
                                value: selectedCardId,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                                isExpanded: true,
                                items: creditoTarjetas.map((t) {
                                  final ultimos = t.numeroEnmascarado.length > 4
                                      ? t.numeroEnmascarado.substring(t.numeroEnmascarado.length - 4)
                                      : t.numeroEnmascarado;
                                  final saldoDisp = t.saldoDisponible ?? 0.0;
                                  return DropdownMenuItem(
                                    value: t.id,
                                    child: Text(
                                      '${t.marca} ${t.tipoFormateado} •••• $ultimos (S/ ${saldoDisp.toStringAsFixed(2)})',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => selectedCardId = val),
                              );
                            },
                            loading: () => const LinearProgressIndicator(color: Color(0xFFED0006)),
                            error: (_, __) => const Text('Error al cargar tarjetas'),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Datos del contrato
                        TextFormField(
                          controller: contractController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Número de Contrato / Suministro',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Monto
                        TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Monto a pagar',
                            prefixText: 'S/ ',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón de Pagar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: pagoState.isLoading
                                ? null
                                : () async {
                                    final contract = contractController.text.trim();
                                    final amount = double.tryParse(amountController.text);
                                    if (contract.isEmpty || amount == null || amount <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Por favor, completa todos los campos con valores válidos')),
                                      );
                                      return;
                                    }

                                    final success = await ref
                                        .read(pagoServicioViewModelProvider.notifier)
                                        .pagarServicio(
                                          cuentaId: paymentMethod == 'cuenta' ? selectedAccountId : null,
                                          tarjetaId: paymentMethod == 'tarjeta' ? selectedCardId : null,
                                          servicio: serviceType,
                                          proveedor: provider,
                                          numeroContrato: contract,
                                          monto: amount,
                                        );

                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('¡Servicio pagado exitosamente!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context); // Cierra bottomsheet
                                    } else if (context.mounted) {
                                      final errorMsg = ref.read(pagoServicioViewModelProvider).error ?? 'Error desconocido';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Fallo al pagar: $errorMsg'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFED0006),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: pagoState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Pagar Servicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text('Pago de Servicios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Buscador
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFED0006),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar empresa o servicio...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Categorías
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categorías', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryIcon(Icons.phone_android, 'Telefonía\ny Móviles', Colors.blue, 'Movistar Celular', 'telefono'),
                        _buildCategoryIcon(Icons.water_drop, 'Agua', Colors.lightBlue, 'Sedapal', 'agua'),
                        _buildCategoryIcon(Icons.lightbulb_outline, 'Luz', Colors.amber, 'Enel', 'luz'),
                        _buildCategoryIcon(Icons.account_balance, 'Instituciones', Colors.indigo, 'Banco de la Nación', 'otro'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryIcon(Icons.school, 'Colegios y\nUniversidades', Colors.green, 'UPC Colegiaturas', 'universidad'),
                        _buildCategoryIcon(Icons.monitor, 'Internet\ny Cable', Colors.deepOrange, 'Claro Hogar', 'internet'),
                        _buildCategoryIcon(Icons.credit_card, 'Tarjetas de\nCrédito', const Color(0xFFED0006), 'Scotia Tarjetas', 'otro'),
                        _buildCategoryIcon(Icons.more_horiz, 'Más\nServicios', Colors.grey.shade600, 'Otros Servicios', 'otro'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Servicios Frecuentes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text('Pagos Frecuentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),
                  _buildFrequentPaymentCard('Luz Sur', 'Suministro: 1234567', 'Último pago: hace 15 días', Icons.lightbulb_outline, Colors.amber, 'luz', '1234567'),
                  const SizedBox(height: 12),
                  _buildFrequentPaymentCard('Sedapal', 'Suministro: 7654321', 'Último pago: hace 12 días', Icons.water_drop, Colors.lightBlue, 'agua', '7654321'),
                  const SizedBox(height: 12),
                  _buildFrequentPaymentCard('Claro Móvil', 'Celular: 987654321', 'Último pago: hace 5 días', Icons.phone_android, Colors.red, 'telefono', '987654321'),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color color, String provider, String serviceType) {
    return Expanded(
      child: InkWell(
        onTap: () {
          _showPaymentSheet(context, provider, serviceType);
        },
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequentPaymentCard(String title, String subtitle, String trailing, IconData icon, Color color, String serviceType, String contract) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black87, fontSize: 13)),
            Text(trailing, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
        onTap: () {
          _showPaymentSheet(context, title, serviceType, defaultContract: contract);
        },
      ),
    );
  }
}