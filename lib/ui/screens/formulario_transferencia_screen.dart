import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/cuenta_viewmodel.dart';

class FormularioTransferenciaScreen extends ConsumerStatefulWidget {
  final String tipoTransferencia; // 'propias', 'terceros', 'interbancario'

  const FormularioTransferenciaScreen({
    super.key,
    required this.tipoTransferencia,
  });

  @override
  ConsumerState<FormularioTransferenciaScreen> createState() => _FormularioTransferenciaScreenState();
}

class _FormularioTransferenciaScreenState extends ConsumerState<FormularioTransferenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _cuentaOrigenId;
  String? _cuentaDestinoId;
  String? _bancoDestino;
  
  final _cuentaDestinoController = TextEditingController();
  final _montoController = TextEditingController();
  final _conceptoController = TextEditingController();

  String get _tituloAppbar {
    switch (widget.tipoTransferencia) {
      case 'propias': return 'Entre mis cuentas';
      case 'terceros': return 'A terceros Scotiabank';
      case 'interbancario': return 'A otros bancos';
      default: return 'Transferencia';
    }
  }

  @override
  void dispose() {
    _cuentaDestinoController.dispose();
    _montoController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  void _procesarTransferencia() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Procesando transferencia...'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Simulación de delay de API
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Transferencia realizada con éxito!'),
              backgroundColor: Colors.green,
            ),
          );
          // Cierra la pantalla y regresa al inicio/movimientos
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
        title: Text(
          _tituloAppbar,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: cuentasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
        error: (error, _) => Center(child: Text('Error al cargar cuentas: $error', style: const TextStyle(color: Colors.black87))),
        data: (cuentas) {
          if (cuentas.isEmpty) {
            return const Center(child: Text('No tienes cuentas disponibles.', style: TextStyle(color: Colors.black87)));
          }

          // Para la transferencia entre propias cuentas, evitamos enviar a la misma cuenta seleccionada.
          final cuentasDestinoDisponibles = cuentas.where((c) => (c as dynamic).id != _cuentaOrigenId).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cuenta origen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Selecciona la cuenta de cargo'),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    value: _cuentaOrigenId,
                    items: cuentas.map((c) {
                      final String id = (c as dynamic).id;
                      final String numCuenta = (c as dynamic).numeroCuenta;
                      final String ultimos = numCuenta.length > 4 ? numCuenta.substring(numCuenta.length - 4) : numCuenta;
                      final String moneda = (c as dynamic).moneda == 'PEN' ? 'S/' : '\$';
                      final String saldo = (c as dynamic).saldo.toStringAsFixed(2);
                      
                      return DropdownMenuItem(
                        value: id,
                        child: Text('Cuenta •••• $ultimos ($moneda $saldo)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _cuentaOrigenId = val;
                        if (_cuentaDestinoId == val) _cuentaDestinoId = null; // Reiniciar destino si es igual al origen
                      });
                    },
                    validator: (v) => v == null ? 'Selecciona una cuenta de origen' : null,
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Cuenta destino', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 8),
                  
                  // DINÁMICO DEPENDIENDO DE LA RUTA ELEGIDA
                  if (widget.tipoTransferencia == 'propias') ...[
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Selecciona la cuenta de destino'),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black87, fontSize: 15),
                      value: _cuentaDestinoId,
                      items: cuentasDestinoDisponibles.map((c) {
                        final String num = (c as dynamic).numeroCuenta;
                        final String u = num.length > 4 ? num.substring(num.length - 4) : num;
                        return DropdownMenuItem(value: (c as dynamic).id, child: Text('Cuenta •••• $u'));
                      }).toList(),
                      onChanged: (val) => setState(() => _cuentaDestinoId = val),
                      validator: (v) => v == null ? 'Selecciona la cuenta destino' : null,
                    ),
                  ] else if (widget.tipoTransferencia == 'interbancario') ...[
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Selecciona el banco destino'),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black87, fontSize: 15),
                      value: _bancoDestino,
                      items: ['BCP', 'BBVA', 'Interbank', 'BanBif', 'Pichincha']
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (val) => setState(() => _bancoDestino = val),
                      validator: (v) => v == null ? 'Selecciona el banco' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cuentaDestinoController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87, fontSize: 15),
                      maxLength: 20,
                      decoration: _inputDecoration('Ingresa el CCI (20 dígitos)'),
                      validator: (v) => (v == null || v.length != 20) ? 'Debe tener exactamente 20 dígitos' : null,
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _cuentaDestinoController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87, fontSize: 15),
                      decoration: _inputDecoration('Número de cuenta Scotiabank'),
                      validator: (v) => (v == null || v.length < 10) ? 'Número de cuenta inválido' : null,
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text('Monto a transferir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    decoration: _inputDecoration('0.00').copyWith(prefixText: 'S/ '),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa un monto';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Monto inválido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),
                  const Text('Concepto (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _conceptoController,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    decoration: _inputDecoration('Ej. Pago del alquiler...'),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _procesarTransferencia,
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

  // Método auxiliar para no repetir el estilo de los inputs
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixStyle: const TextStyle(color: Colors.black87, fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      counterText: '', // Oculta el contador del maxLength
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFED0006), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}