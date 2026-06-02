import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodel/seguro_viewmodel.dart';

class SegurosScreen extends ConsumerStatefulWidget {
  const SegurosScreen({super.key});

  @override
  ConsumerState<SegurosScreen> createState() => _SegurosScreenState();
}

class _SegurosScreenState extends ConsumerState<SegurosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormatterPEN = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
  final currencyFormatterUSD = NumberFormat.currency(locale: 'en_US', symbol: '\$ ');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segurosAsync = ref.watch(segurosProvider);
    final siniestrosAsync = ref.watch(siniestrosProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mis Seguros',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Mis Pólizas'),
            Tab(text: 'Siniestros / Reclamos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // PESTAÑA 1: MIS PÓLIZAS
          segurosAsync.when(
            data: (seguros) {
              if (seguros.isEmpty) {
                return _buildEmptyState(
                  Icons.shield_outlined,
                  'No tienes seguros contratados',
                  'Protege lo que más quieres contratando SOAT, Seguro de Tarjeta o Salud desde nuestra banca digital.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: seguros.length,
                itemBuilder: (context, index) {
                  final seguro = seguros[index];
                  return _buildPolicyCard(seguro);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),

          // PESTAÑA 2: SINIESTROS / RECLAMOS
          siniestrosAsync.when(
            data: (siniestros) {
              if (siniestros.isEmpty) {
                return _buildEmptyState(
                  Icons.receipt_long_outlined,
                  'No tienes reclamos reportados',
                  'Aquí podrás hacer el seguimiento de cualquier solicitud de cobertura o siniestro declarado.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: siniestros.length,
                itemBuilder: (context, index) {
                  final siniestro = siniestros[index];
                  // Buscamos el seguro asociado
                  final segurosList = segurosAsync.value ?? [];
                  final seguroAsociado = segurosList.firstWhere(
                    (s) => s.id == siniestro.seguroId,
                    orElse: () => seguroFallback(siniestro.seguroId),
                  );

                  return _buildClaimCard(siniestro, seguroAsociado);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  dynamic seguroFallback(String id) {
    return null;
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFED0006).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: const Color(0xFFED0006)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard(dynamic seguro) {
    final formatter = seguro.moneda == 'PEN' ? currencyFormatterPEN : currencyFormatterUSD;
    
    Color badgeColor;
    Color textBadgeColor;
    String estadoText;

    switch (seguro.estado) {
      case 'vigente':
        badgeColor = Colors.green.shade50;
        textBadgeColor = Colors.green.shade700;
        estadoText = 'Vigente';
        break;
      case 'siniestro':
        badgeColor = Colors.amber.shade50;
        textBadgeColor = Colors.amber.shade800;
        estadoText = 'Siniestro Declarado';
        break;
      case 'cancelado':
        badgeColor = Colors.grey.shade100;
        textBadgeColor = Colors.grey.shade600;
        estadoText = 'Cancelado';
        break;
      case 'vencido':
        badgeColor = Colors.grey.shade100;
        textBadgeColor = Colors.grey.shade600;
        estadoText = 'Vencido';
        break;
      default:
        badgeColor = Colors.grey.shade50;
        textBadgeColor = Colors.grey.shade700;
        estadoText = seguro.estado;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estadoText,
                    style: TextStyle(color: textBadgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Pol. ${seguro.numeroPoliza}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              seguro.tipoFormateado,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prima Mensual', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(formatter.format(seguro.primaMensual), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                if (seguro.sumaAsegurada != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Suma Asegurada', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(formatter.format(seguro.sumaAsegurada), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFED0006))),
                    ],
                  ),
              ],
            ),
            if (seguro.estado == 'vigente') ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showReportarSiniestroModal(context, seguro),
                  icon: const Icon(Icons.campaign_outlined, size: 20, color: Color(0xFFED0006)),
                  label: const Text('Declarar Siniestro / Reportar', style: TextStyle(color: Color(0xFFED0006), fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClaimCard(dynamic siniestro, dynamic seguro) {
    final formatter = seguro?.moneda == 'PEN' ? currencyFormatterPEN : currencyFormatterUSD;
    
    Color badgeColor;
    Color textBadgeColor;

    switch (siniestro.estado) {
      case 'en_revision':
        badgeColor = Colors.amber.shade50;
        textBadgeColor = Colors.amber.shade800;
        break;
      case 'aprobado':
        badgeColor = Colors.green.shade50;
        textBadgeColor = Colors.green.shade700;
        break;
      case 'rechazado':
        badgeColor = Colors.red.shade50;
        textBadgeColor = Colors.red.shade700;
        break;
      case 'pagado':
        badgeColor = Colors.blue.shade50;
        textBadgeColor = Colors.blue.shade700;
        break;
      default:
        badgeColor = Colors.grey.shade50;
        textBadgeColor = Colors.grey.shade700;
    }

    final String seguroNombre = seguro?.tipoFormateado ?? 'Seguro de Cobertura';
    final String fechaOc = DateFormat('dd/MM/yyyy').format(siniestro.fechaOcurrencia);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    siniestro.estadoFormateado,
                    style: TextStyle(color: textBadgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Incidente: $fechaOc',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              seguroNombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              siniestro.descripcion,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5, height: 1.3),
            ),
            if (siniestro.montoReclamado != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monto Reclamado', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(formatter.format(siniestro.montoReclamado), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  if (siniestro.montoLiquidado != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Monto Liquidado', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(formatter.format(siniestro.montoLiquidado), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReportarSiniestroModal(BuildContext context, dynamic seguro) {
    final descripcionController = TextEditingController();
    final montoController = TextEditingController();
    DateTime fechaSeleccionada = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final String monedaSymbol = seguro.moneda == 'PEN' ? 'S/ ' : '\$ ';

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Declarar Siniestro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 8),
                  Text(seguro.tipoFormateado, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  const SizedBox(height: 20),
                  const Text('Descripción de los hechos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descripcionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe brevemente lo ocurrido (robo, accidente, pérdida, etc.)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Monto Estimado de Reclamo (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: monedaSymbol,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Fecha del Suceso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: fechaSeleccionada,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) {
                        setModalState(() => fechaSeleccionada = fecha);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd/MM/yyyy').format(fechaSeleccionada)),
                          const Icon(Icons.calendar_today_outlined, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final desc = descripcionController.text;
                        if (desc.isEmpty || desc.length < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, ingresa una descripción de al menos 10 caracteres')),
                          );
                          return;
                        }

                        final double monto = double.tryParse(montoController.text) ?? 0.0;

                        final ok = await ref.read(seguroNotifierProvider.notifier).reportarSiniestro(
                              seguroId: seguro.id,
                              descripcion: desc,
                              montoReclamado: monto,
                              fechaOcurrencia: fechaSeleccionada,
                            );

                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reclamo declarado con éxito. Está bajo revisión.')),
                          );
                          _tabController.animateTo(1); // Moverse a la pestaña de Reclamos
                        } else {
                          final err = ref.read(seguroNotifierProvider).error ?? 'Error desconocido';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $err')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0006),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Enviar Reclamo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
