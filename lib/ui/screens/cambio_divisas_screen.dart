import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/cuenta_viewmodel.dart';

class CambioDivisasScreen extends ConsumerStatefulWidget {
  const CambioDivisasScreen({super.key});

  @override
  ConsumerState<CambioDivisasScreen> createState() => _CambioDivisasScreenState();
}

class _CambioDivisasScreenState extends ConsumerState<CambioDivisasScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _cuentaOrigenId;
  String? _cuentaDestinoId;
  final _montoController = TextEditingController();

  // Tasas de cambio simuladas (idealmente vendrían de un ViewModel)
  final double tasaCompra = 3.720;
  final double tasaVenta = 3.750;

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  void _procesarCambio() {
    if (_formKey.currentState!.validate()) {
      if (_cuentaOrigenId == _cuentaDestinoId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las cuentas de origen y destino deben ser distintas'), backgroundColor: Colors.red),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procesando operación...'), backgroundColor: Colors.orange),
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Cambio de divisas realizado con éxito!'), backgroundColor: Colors.green),
          );
          context.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuentasAsync = ref.watch(cuentasProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text(
          'Cambio de Dólares',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: cuentasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
        error: (error, _) => Center(child: Text('Error al cargar cuentas: $error', style: const TextStyle(color: Colors.black87))),
        data: (cuentas) {
          if (cuentas.length < 2) {
            return const Center(child: Text('Necesitas al menos 2 cuentas para realizar el cambio de moneda.', style: TextStyle(color: Colors.black87)));
          }

          // Excluimos la cuenta origen de los destinos disponibles
          final cuentasDestinoDisponibles = cuentas.where((c) => (c as dynamic).id != _cuentaOrigenId).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta informativa de tipo de cambio
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Compra', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('S/ ${tasaCompra.toStringAsFixed(3)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFED0006))),
                          ],
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        Column(
                          children: [
                            const Text('Venta', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('S/ ${tasaVenta.toStringAsFixed(3)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFED0006))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Cuenta origen (Cargo)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('¿De dónde saldrá el dinero?'),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    value: _cuentaOrigenId,
                    items: cuentas.map((c) {
                      final dynamic cuenta = c;
                      final String ultimos = cuenta.numeroCuenta.length > 4 ? cuenta.numeroCuenta.substring(cuenta.numeroCuenta.length - 4) : cuenta.numeroCuenta;
                      final String moneda = cuenta.moneda == 'PEN' ? 'S/' : '\$';
                      return DropdownMenuItem<String>(value: cuenta.id as String, child: Text('Cuenta $moneda •••• $ultimos ($moneda ${cuenta.saldo.toStringAsFixed(2)})'));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _cuentaOrigenId = val;
                        if (_cuentaDestinoId == val) _cuentaDestinoId = null; // Reiniciar destino
                      });
                    },
                    validator: (v) => v == null ? 'Selecciona una cuenta de origen' : null,
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Cuenta destino (Abono)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('¿A dónde ingresará el dinero?'),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    value: _cuentaDestinoId,
                    items: cuentasDestinoDisponibles.map((c) {
                      final dynamic cuenta = c;
                      final String ultimos = cuenta.numeroCuenta.length > 4 ? cuenta.numeroCuenta.substring(cuenta.numeroCuenta.length - 4) : cuenta.numeroCuenta;
                      final String moneda = cuenta.moneda == 'PEN' ? 'S/' : '\$';
                      return DropdownMenuItem<String>(value: cuenta.id as String, child: Text('Cuenta $moneda •••• $ultimos'));
                    }).toList(),
                    onChanged: (val) => setState(() => _cuentaDestinoId = val),
                    validator: (v) => v == null ? 'Selecciona la cuenta destino' : null,
                  ),

                  const SizedBox(height: 24),
                  const Text('Monto a cambiar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    decoration: _inputDecoration('0.00'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa un monto';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Monto inválido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _procesarCambio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0006),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFED0006), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}