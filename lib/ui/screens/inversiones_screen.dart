import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodel/inversion_viewmodel.dart';
import '../viewmodel/cuenta_viewmodel.dart';

class InversionesScreen extends ConsumerStatefulWidget {
  const InversionesScreen({super.key});

  @override
  ConsumerState<InversionesScreen> createState() => _InversionesScreenState();
}

class _InversionesScreenState extends ConsumerState<InversionesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormatterPEN = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
  final currencyFormatterUSD = NumberFormat.currency(locale: 'en_US', symbol: '\$ ');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final depositosAsync = ref.watch(depositosPlazoProvider);
    final fondosAsync = ref.watch(fondosMutuosProvider);
    final bolsaAsync = ref.watch(historialBolsaProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Inversiones Scotiabank',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Plazo Fijo'),
            Tab(text: 'Fondos Mutuos'),
            Tab(text: 'Scotia Bolsa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── PESTAÑA 1: PLAZO FIJO ──────────────────────────
          _buildPlazoFijoTab(depositosAsync),

          // ── PESTAÑA 2: FONDOS MUTUOS ────────────────────────
          _buildFondosMutuosTab(fondosAsync),

          // ── PESTAÑA 3: SCOTIA BOLSA ─────────────────────────
          _buildScotiaBolsaTab(bolsaAsync),
        ],
      ),
    );
  }

  // ==========================================
  // PLAZO FIJO TAB
  // ==========================================
  Widget _buildPlazoFijoTab(AsyncValue<List<dynamic>> depositosAsync) {
    return Column(
      children: [
        _buildPlazoFijoHeader(depositosAsync),
        Expanded(
          child: depositosAsync.when(
            data: (depositos) {
              if (depositos.isEmpty) {
                return _buildEmptyState(
                  Icons.lock_clock_outlined,
                  'No tienes Plazos Fijos activos',
                  'Haz crecer tus ahorros de forma segura con tasas preferenciales desde 30 hasta 360 días.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: depositos.length,
                itemBuilder: (context, index) {
                  final dep = depositos[index];
                  return _buildPlazoFijoCard(dep);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildPlazoFijoHeader(AsyncValue<List<dynamic>> depositosAsync) {
    final double totalSoles = depositosAsync.maybeWhen(
      data: (list) => list.where((d) => d.moneda == 'PEN' && d.estado == 'activo').fold<double>(0.0, (sum, d) => sum + d.monto),
      orElse: () => 0.0,
    );
    final double totalDolares = depositosAsync.maybeWhen(
      data: (list) => list.where((d) => d.moneda == 'USD' && d.estado == 'activo').fold<double>(0.0, (sum, d) => sum + d.monto),
      orElse: () => 0.0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFED0006),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Plazo Fijo', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                currencyFormatterPEN.format(totalSoles),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormatterUSD.format(totalDolares),
                style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showCrearPlazoFijoModal(context),
            icon: const Icon(Icons.add, size: 18, color: Color(0xFFED0006)),
            label: const Text('Constituir', style: TextStyle(color: Color(0xFFED0006), fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlazoFijoCard(dynamic dep) {
    final formatter = dep.moneda == 'PEN' ? currencyFormatterPEN : currencyFormatterUSD;
    final String fechaVencText = DateFormat('dd/MM/yyyy').format(dep.fechaVenc);
    final double rendimiento = dep.rendimiento ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock, color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Tasa: ${dep.tasaAnual}% TEA',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  dep.estado.toUpperCase(),
                  style: TextStyle(
                    color: dep.estado == 'activo' ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monto Invertido', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(formatter.format(dep.monto), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Interés Ganado', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('+ ${formatter.format(rendimiento)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vence: $fechaVencText', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(
                  dep.renovacionAuto ? 'Renovación Auto: SÍ' : 'Renovación Auto: NO',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FONDOS MUTUOS TAB
  // ==========================================
  Widget _buildFondosMutuosTab(AsyncValue<List<dynamic>> fondosAsync) {
    final double totalSoles = fondosAsync.maybeWhen(
      data: (list) => list.where((f) => f.moneda == 'PEN' && f.estado == 'activo').fold<double>(0.0, (sum, f) => sum + (f.valorActual ?? f.montoInvertido)),
      orElse: () => 0.0,
    );
    final double totalDolares = fondosAsync.maybeWhen(
      data: (list) => list.where((f) => f.moneda == 'USD' && f.estado == 'activo').fold<double>(0.0, (sum, f) => sum + (f.valorActual ?? f.montoInvertido)),
      orElse: () => 0.0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de saldo total fondos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Valor Total Fondos Mutuos', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(currencyFormatterPEN.format(totalSoles), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(currencyFormatterUSD.format(totalDolares), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.grey)),
                  ],
                ),
                Icon(Icons.analytics_outlined, size: 36, color: Colors.red.shade700),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Mis Fondos Suscritos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          fondosAsync.when(
            data: (fondos) {
              final activos = fondos.where((f) => f.estado == 'activo').toList();
              if (activos.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('No tienes participaciones en Fondos Mutuos.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ),
                );
              }

              return Column(
                children: activos.map((f) => _buildFondoSuscritoCard(f)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Error: $e'),
          ),
          const SizedBox(height: 24),
          const Text('Fondos Mutuos Disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildFondoDisponibleCard('Fondo Conservador Corto Plazo', 'conservador', 'PEN', 4.25, 1.2541, 300),
          _buildFondoDisponibleCard('Fondo Moderado Balanceado', 'moderado', 'USD', 6.80, 2.5028, 500),
          _buildFondoDisponibleCard('Fondo Agresivo Acciones', 'agresivo', 'USD', 12.45, 4.1039, 1000),
          _buildFondoDisponibleCard('Fondo Exterior Global Tech', 'exterior', 'USD', 15.90, 8.4520, 100),
        ],
      ),
    );
  }

  Widget _buildFondoSuscritoCard(dynamic f) {
    final formatter = f.moneda == 'PEN' ? currencyFormatterPEN : currencyFormatterUSD;
    final double rent = f.rentabilidad ?? 0.0;
    final double valorAct = f.valorActual ?? (f.cuotas * f.valorCuota);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(f.fondo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  '${rent >= 0 ? '+' : ''}${rent.toStringAsFixed(2)}%',
                  style: TextStyle(color: rent >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(f.tipoFondoFormateado, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monto Invertido', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(formatter.format(f.montoInvertido), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Cuotas', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(f.cuotas.toStringAsFixed(4), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Valorización', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(formatter.format(valorAct), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFED0006))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRescatarFondoModal(context, f),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFED0006),
                      side: const BorderSide(color: Color(0xFFED0006)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Rescatar / Retirar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSuscribirFondoModal(context, f.fondo, f.tipoFondo, f.moneda, f.valorCuota, f.inversionMin),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFED0006),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Suscribir más'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFondoDisponibleCard(String nombre, String tipo, String moneda, double tasaSimulada, double valorCuota, double min) {
    final symbol = moneda == 'PEN' ? 'S/ ' : '\$ ';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Mínimo: $symbol$min • V. Cuota: $symbol${valorCuota.toStringAsFixed(4)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Rent. Histórica: +$tasaSimulada%', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _showSuscribirFondoModal(context, nombre, tipo, moneda, valorCuota, min),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFED0006),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Suscribir'),
        ),
      ),
    );
  }

  // ==========================================
  // SCOTIA BOLSA TAB
  // ==========================================
  Widget _buildScotiaBolsaTab(AsyncValue<List<dynamic>> bolsaAsync) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildBolsaActionCard(),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Historial de Órdenes Bursátiles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: bolsaAsync.when(
            data: (ordenes) {
              if (ordenes.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No tienes transacciones de bolsa registradas.', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final o = ordenes[index];
                    return _buildBolsaOrderCard(o);
                  },
                  childCount: ordenes.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildBolsaActionCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.trending_up, color: Colors.red.shade700),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trading Scotia Bolsa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Opera en el mercado nacional y de EE.UU.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showBolsaModal(context, isCompra: false),
                    icon: const Icon(Icons.sell_outlined, size: 18),
                    label: const Text('Vender Acción'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFED0006),
                      side: const BorderSide(color: Color(0xFFED0006)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showBolsaModal(context, isCompra: true),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.white),
                    label: const Text('Comprar Acción'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFED0006),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBolsaOrderCard(dynamic o) {
    final bool isCompra = o.operacion == 'compra';
    final formatter = o.moneda == 'PEN' ? currencyFormatterPEN : currencyFormatterUSD;
    final String fechaText = DateFormat('dd/MM/yyyy hh:mm a').format(o.fecha);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCompra ? Colors.red.shade50 : Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompra ? Icons.shopping_basket_outlined : Icons.monetization_on_outlined,
                  color: isCompra ? Colors.red.shade700 : Colors.green.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${isCompra ? 'COMPRA' : 'VENTA'} ${o.ticker}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${o.cantidad} acc. a ${formatter.format(o.precioUnitario)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCompra ? '-' : '+'}${formatter.format(o.montoTotal)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: isCompra ? Colors.black87 : Colors.green, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(fechaText, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODALES Y FORMULARIOS
  // ==========================================
  void _showCrearPlazoFijoModal(BuildContext context) {
    final montoController = TextEditingController();
    String moneda = 'PEN';
    int plazoDias = 90;
    String? cuentaId;
    bool renovacionAuto = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cuentasAsync = ref.watch(cuentasProvider);
            double tasa = 5.80; // Tasa por defecto para 90d PEN
            
            // Lógica de tasas dinámicas simulada
            if (moneda == 'PEN') {
              if (plazoDias == 30) tasa = 5.50;
              if (plazoDias == 90) tasa = 5.80;
              if (plazoDias == 180) tasa = 6.00;
              if (plazoDias == 360) tasa = 6.25;
            } else {
              if (plazoDias == 30) tasa = 2.50;
              if (plazoDias == 90) tasa = 2.80;
              if (plazoDias == 180) tasa = 3.00;
              if (plazoDias == 360) tasa = 3.25;
            }

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
                  const Text('Constituir Plazo Fijo Digital', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 16),
                  const Text('Moneda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Soles (S/)'),
                        selected: moneda == 'PEN',
                        onSelected: (val) {
                          if (val) setModalState(() => {moneda = 'PEN', cuentaId = null});
                        },
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('Dólares (\$)'),
                        selected: moneda == 'USD',
                        onSelected: (val) {
                          if (val) setModalState(() => {moneda = 'USD', cuentaId = null});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Plazo (Días)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [30, 90, 180, 360].map((d) {
                      return ChoiceChip(
                        label: Text('$d días'),
                        selected: plazoDias == d,
                        onSelected: (val) {
                          if (val) setModalState(() => plazoDias = d);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Monto a Invertir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'ej. 10000.00',
                      prefixText: moneda == 'PEN' ? 'S/ ' : '\$ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Debitar de la cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  cuentasAsync.when(
                    data: (cuentas) {
                      final cuentasFiltradas = cuentas.where((c) => c.moneda == moneda).toList();
                      if (cuentasFiltradas.isEmpty) {
                        return const Text('No tienes cuentas en esta moneda.', style: TextStyle(color: Colors.red));
                      }
                      cuentaId ??= cuentasFiltradas.first.id;

                      return DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: cuentaId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: cuentasFiltradas.map((c) {
                          final u = c.numeroCuenta.length > 4 ? c.numeroCuenta.substring(c.numeroCuenta.length - 4) : c.numeroCuenta;
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text('Cuenta •••• $u (Saldo: ${moneda == 'PEN' ? 'S/' : '\$'} ${c.saldo})'),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => cuentaId = val),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tasa de Rendimiento Anual:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text('$tasa% TEA', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Renovación automática al vencimiento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    value: renovacionAuto,
                    activeColor: const Color(0xFFED0006),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setModalState(() => renovacionAuto = val),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final double? monto = double.tryParse(montoController.text);
                        if (monto == null || monto <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ingresa un monto de inversión válido')),
                          );
                          return;
                        }

                        if (cuentaId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selecciona una cuenta de origen')),
                          );
                          return;
                        }

                        final ok = await ref.read(inversionNotifierProvider.notifier).crearDepositoPlazo(
                              monto: monto,
                              moneda: moneda,
                              plazoDias: plazoDias,
                              tasaAnual: tasa,
                              cuentaOrigenId: cuentaId!,
                              renovacionAuto: renovacionAuto,
                            );

                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Plazo Fijo Digital constituido con éxito')),
                          );
                        } else {
                          final err = ref.read(inversionNotifierProvider).error ?? 'Error desconocido';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fallo: $err')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0006),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirmar Constitución', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showSuscribirFondoModal(BuildContext context, String nombreFondo, String tipoFondo, String moneda, double valorCuota, double min) {
    final montoController = TextEditingController();
    String? cuentaId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cuentasAsync = ref.watch(cuentasProvider);
            final String symbol = moneda == 'PEN' ? 'S/ ' : '\$ ';

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
                  const Text('Suscribir Fondo Mutuo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(nombreFondo, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  const SizedBox(height: 20),
                  Text('Monto a Suscribir (Mínimo: $symbol$min)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: symbol,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Cargar a la cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  cuentasAsync.when(
                    data: (cuentas) {
                      final cuentasFiltradas = cuentas.where((c) => c.moneda == moneda).toList();
                      if (cuentasFiltradas.isEmpty) {
                        return const Text('No tienes cuentas disponibles en esta moneda.', style: TextStyle(color: Colors.red));
                      }
                      cuentaId ??= cuentasFiltradas.first.id;

                      return DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: cuentaId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: cuentasFiltradas.map((c) {
                          final u = c.numeroCuenta.length > 4 ? c.numeroCuenta.substring(c.numeroCuenta.length - 4) : c.numeroCuenta;
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text('Cuenta •••• $u (Saldo: ${moneda == 'PEN' ? 'S/' : '\$'} ${c.saldo})'),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => cuentaId = val),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final double? monto = double.tryParse(montoController.text);
                        if (monto == null || monto < min) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ingresa un monto de suscripción válido (mínimo $symbol$min)')),
                          );
                          return;
                        }

                        if (cuentaId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selecciona una cuenta de origen')),
                          );
                          return;
                        }

                        final ok = await ref.read(inversionNotifierProvider.notifier).suscribirFondoMutuo(
                              fondoNombre: nombreFondo,
                              tipoFondo: tipoFondo,
                              moneda: moneda,
                              monto: monto,
                              valorCuota: valorCuota,
                              inversionMin: min,
                              cuentaOrigenId: cuentaId!,
                            );

                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Suscripción procesada con éxito')),
                          );
                        } else {
                          final err = ref.read(inversionNotifierProvider).error ?? 'Error de conexión';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fallo: $err')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0006),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirmar Suscripción', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showRescatarFondoModal(BuildContext context, dynamic fondo) {
    final montoController = TextEditingController();
    String? cuentaId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cuentasAsync = ref.watch(cuentasProvider);
            final String symbol = fondo.moneda == 'PEN' ? 'S/ ' : '\$ ';
            final double valorMax = fondo.valorActual ?? (fondo.cuotas * fondo.valorCuota);

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
                  const Text('Rescatar Participaciones de Fondo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(fondo.fondo, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  const SizedBox(height: 20),
                  Text('Monto a Rescatar (Disponible: $symbol${valorMax.toStringAsFixed(2)})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: symbol,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Abonar en la cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  cuentasAsync.when(
                    data: (cuentas) {
                      final cuentasFiltradas = cuentas.where((c) => c.moneda == fondo.moneda).toList();
                      if (cuentasFiltradas.isEmpty) {
                        return const Text('No tienes cuentas disponibles en esta moneda.', style: TextStyle(color: Colors.red));
                      }
                      cuentaId ??= cuentasFiltradas.first.id;

                      return DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: cuentaId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: cuentasFiltradas.map((c) {
                          final u = c.numeroCuenta.length > 4 ? c.numeroCuenta.substring(c.numeroCuenta.length - 4) : c.numeroCuenta;
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text('Cuenta •• $u (Saldo: ${fondo.moneda == 'PEN' ? 'S/' : '\$'} ${c.saldo})'),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => cuentaId = val),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final double? monto = double.tryParse(montoController.text);
                        if (monto == null || monto <= 0 || monto > valorMax) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ingresa un monto de rescate válido (no mayor al disponible)')),
                          );
                          return;
                        }

                        if (cuentaId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selecciona una cuenta de destino')),
                          );
                          return;
                        }

                        final ok = await ref.read(inversionNotifierProvider.notifier).rescatarFondoMutuo(
                              fondoId: fondo.id,
                              monto: monto,
                              cuentaDestinoId: cuentaId!,
                            );

                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rescate procesado con éxito. Fondos abonados.')),
                          );
                        } else {
                          final err = ref.read(inversionNotifierProvider).error ?? 'Error de red';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fallo: $err')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0006),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirmar Rescate', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showBolsaModal(BuildContext context, {required bool isCompra}) {
    final tickerController = TextEditingController();
    final cantidadController = TextEditingController();
    final precioController = TextEditingController();
    String moneda = 'USD';
    String? cuentaId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cuentasAsync = ref.watch(cuentasProvider);
            final double cant = double.tryParse(cantidadController.text) ?? 0.0;
            final double prec = double.tryParse(precioController.text) ?? 0.0;
            final double subtotal = cant * prec;
            final double comision = subtotal * 0.0075; // Comisión fija de 0.75%
            final double total = isCompra ? (subtotal + comision) : (subtotal - comision);

            final String symbol = moneda == 'PEN' ? 'S/ ' : '\$ ';

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
                  Text(
                    isCompra ? 'Scotia Bolsa: Comprar Acciones' : 'Scotia Bolsa: Vender Acciones',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ticker / Nemónico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: tickerController,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'ej. AAPL',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Moneda de Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              value: moneda,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'USD', child: Text('Dólares (USD)')),
                                DropdownMenuItem(value: 'PEN', child: Text('Soles (PEN)')),
                              ],
                              onChanged: (val) => setModalState(() => {moneda = val ?? 'USD', cuentaId = null}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: cantidadController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: 'ej. 10',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (v) => setModalState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Precio Límite', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: precioController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                prefixText: symbol,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (v) => setModalState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isCompra ? 'Cuenta para debitar cargo' : 'Cuenta de abono',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  cuentasAsync.when(
                    data: (cuentas) {
                      final cuentasFiltradas = cuentas.where((c) => c.moneda == moneda).toList();
                      if (cuentasFiltradas.isEmpty) {
                        return const Text('No tienes cuentas en esta moneda.', style: TextStyle(color: Colors.red));
                      }
                      cuentaId ??= cuentasFiltradas.first.id;

                      return DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: cuentaId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: cuentasFiltradas.map((c) {
                          final u = c.numeroCuenta.length > 4 ? c.numeroCuenta.substring(c.numeroCuenta.length - 4) : c.numeroCuenta;
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text('Cuenta •••• $u (Saldo: ${moneda == 'PEN' ? 'S/' : '\$'} ${c.saldo})'),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => cuentaId = val),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text('$symbol${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Comisión Bolsa (0.75%):', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text('$symbol${comision.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Estimado:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        '$symbol${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFED0006)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final String tick = tickerController.text.trim();
                        final double? c = double.tryParse(cantidadController.text);
                        final double? p = double.tryParse(precioController.text);

                        if (tick.isEmpty || c == null || c <= 0 || p == null || p <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, completa los campos con valores válidos')),
                          );
                          return;
                        }

                        if (cuentaId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selecciona una cuenta asociada')),
                          );
                          return;
                        }

                        bool ok;
                        if (isCompra) {
                          ok = await ref.read(inversionNotifierProvider.notifier).comprarAccion(
                                ticker: tick,
                                cantidad: c,
                                precioUnitario: p,
                                moneda: moneda,
                                comision: comision,
                                cuentaOrigenId: cuentaId!,
                              );
                        } else {
                          ok = await ref.read(inversionNotifierProvider.notifier).venderAccion(
                                ticker: tick,
                                cantidad: c,
                                precioUnitario: p,
                                moneda: moneda,
                                comision: comision,
                                cuentaDestinoId: cuentaId!,
                              );
                        }

                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isCompra ? 'Orden de compra ejecutada en bolsa' : 'Orden de venta ejecutada en bolsa')),
                          );
                        } else {
                          final err = ref.read(inversionNotifierProvider).error ?? 'Error desconocido';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fallo: $err')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0006),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isCompra ? 'Confirmar Compra' : 'Confirmar Venta',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
