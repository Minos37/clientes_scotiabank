import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodel/meses_sin_intereses_viewmodel.dart';
import '../viewmodel/tarjeta_viewmodel.dart';

class MesesSinInteresesScreen extends ConsumerStatefulWidget {
  const MesesSinInteresesScreen({super.key});

  @override
  ConsumerState<MesesSinInteresesScreen> createState() => _MesesSinInteresesScreenState();
}

class _MesesSinInteresesScreenState extends ConsumerState<MesesSinInteresesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form keys and controllers
  final _formKey = GlobalKey<FormState>();
  final _comercioController = TextEditingController();
  final _montoController = TextEditingController();
  
  String? _selectedCardId;
  int _selectedPlazo = 12; // plazo por defecto
  double _simulatedCuota = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Escuchar cambios para calcular la cuota simulada
    _montoController.addListener(_recalculateSimulation);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _comercioController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  void _recalculateSimulation() {
    final monto = double.tryParse(_montoController.text) ?? 0.0;
    setState(() {
      _simulatedCuota = monto > 0 ? (monto / _selectedPlazo) : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final msiListAsync = ref.watch(mesesSinInteresesProvider);
    final tarjetasAsync = ref.watch(tarjetasProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text(
          'Meses Sin Intereses',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Mis Compras MSI'),
            Tab(text: 'Convertir a MSI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña 1: Ver mis Compras MSI
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(mesesSinInteresesProvider);
              ref.invalidate(tarjetasProvider);
            },
            color: const Color(0xFFED0006),
            child: msiListAsync.when(
              data: (msiList) {
                if (msiList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes compras en Meses Sin Intereses.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Puedes comprar en establecimientos afiliados o convertir tus consumos desde la pestaña "Convertir a MSI".',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black38),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: msiList.length,
                  itemBuilder: (context, index) {
                    final msi = msiList[index];
                    final progress = msi.cuotasPagadas / msi.plazoMeses;
                    final totalRestante = (msi.plazoMeses - msi.cuotasPagadas) * msi.cuotaMensual;
                    final isCompletado = msi.estado == 'completado';

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    msi.comercio,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCompletado 
                                        ? Colors.green.shade50 
                                        : const Color(0xFFED0006).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isCompletado ? 'Completado' : 'Activo',
                                    style: TextStyle(
                                      color: isCompletado ? Colors.green : const Color(0xFFED0006),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Inicio: ${DateFormat('dd/MM/yyyy').format(msi.fechaInicio)}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Monto Total', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(
                                      currencyFormatter.format(msi.montoTotal),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Cuota Mensual', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(
                                      currencyFormatter.format(msi.cuotaMensual),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFED0006)),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Restante', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(
                                      currencyFormatter.format(totalRestante),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade800),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            // Cuotas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Cuotas Pagadas: ${msi.cuotasPagadas} de ${msi.plazoMeses}',
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black54),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFED0006)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                color: const Color(0xFFED0006),
                                backgroundColor: Colors.grey.shade200,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
              error: (e, st) => Center(child: Text('Error al cargar datos: $e')),
            ),
          ),

          // Pestaña 2: Convertir a MSI (Simulador)
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Divide tus consumos en cuotas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Convierte compras regulares a meses sin intereses en cualquier momento.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),

                  // Tarjetas
                  tarjetasAsync.when(
                    data: (tarjetas) {
                      final creditCards = tarjetas.where((t) => t.tipo == 'credito' && t.activa).toList();
                      if (creditCards.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                          child: const Text(
                            '⚠️ No tienes tarjetas de crédito activas registradas. No puedes registrar consumos MSI.',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        );
                      }

                      // Iniciar tarjeta
                      if (_selectedCardId == null && creditCards.isNotEmpty) {
                        _selectedCardId = creditCards.first.id;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selecciona tu Tarjeta de Crédito', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedCardId,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            items: creditCards.map((c) {
                              return DropdownMenuItem<String>(
                                value: c.id,
                                child: Text('${c.tipoFormateado} (${c.numeroEnmascarado})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCardId = val;
                              });
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error al cargar tarjetas: $e'),
                  ),
                  const SizedBox(height: 16),

                  // Comercio
                  const Text('Establecimiento o Comercio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _comercioController,
                    decoration: InputDecoration(
                      hintText: 'Ej. Falabella, Ripley, Amazon, etc.',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa el nombre del establecimiento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Monto y Plazo en fila
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Monto Total (S/)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _montoController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Ingresa el monto';
                                }
                                final parsed = double.tryParse(val);
                                if (parsed == null || parsed <= 0) {
                                  return 'Monto inválido';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Plazo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Plazo (Meses)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: _selectedPlazo,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 3, child: Text('3 meses')),
                                DropdownMenuItem(value: 6, child: Text('6 meses')),
                                DropdownMenuItem(value: 9, child: Text('9 meses')),
                                DropdownMenuItem(value: 12, child: Text('12 meses')),
                                DropdownMenuItem(value: 18, child: Text('18 meses')),
                                DropdownMenuItem(value: 24, child: Text('24 meses')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedPlazo = val;
                                    _recalculateSimulation();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Caja de Simulación
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calculate_outlined, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SIMULACIÓN DE CUOTA',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(_simulatedCuota),
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'por $_selectedPlazo meses sin intereses.',
                          style: TextStyle(fontSize: 13, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón registrar
                  ElevatedButton(
                    onPressed: _selectedCardId != null ? _submitConversion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFED0006),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Confirmar Conversión',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitConversion() async {
    if (!_formKey.currentState!.validate() || _selectedCardId == null) return;

    // Confirmar dialog
    final monto = double.parse(_montoController.text);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmar Operación', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro de que deseas convertir esta compra de S/ ${monto.toStringAsFixed(2)} en ${_comercioController.text} a $_selectedPlazo cuotas sin intereses de S/ ${_simulatedCuota.toStringAsFixed(2)}?\n\nEste proceso es irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFED0006)),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFED0006)),
      ),
    );

    final success = await ref.read(mesesSinInteresesNotifierProvider.notifier).registrarCompraMSI(
          tarjetaId: _selectedCardId!,
          comercio: _comercioController.text.trim(),
          montoTotal: monto,
          plazoMeses: _selectedPlazo,
        );

    if (mounted) {
      Navigator.pop(context); // Cerrar loading dialog
    }

    if (success) {
      _showSuccessDialog();
    } else {
      final errorMsg = ref.read(mesesSinInteresesNotifierProvider).error ?? 'Error desconocido';
      _showErrorSnackBar(errorMsg);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 72),
              const SizedBox(height: 16),
              const Text(
                '¡Conversión Exitosa!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu compra en ${_comercioController.text.trim()} ha sido dividida exitosamente en $_selectedPlazo cuotas de S/ ${_simulatedCuota.toStringAsFixed(2)} mensuales sin intereses.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Resetear formulario
                    _comercioController.clear();
                    _montoController.clear();
                    // Ir a la pestaña de "Mis Compras MSI"
                    _tabController.animateTo(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFED0006),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Ver mis compras', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }
}
