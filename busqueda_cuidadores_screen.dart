// ============================================================
// busqueda_cuidadores_screen.dart
// RF06: Buscar cuidadores por ubicación, disponibilidad, precio,
//        experiencia y calificaciones
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'perfil_cuidador_screen.dart';
import 'agendar_cita_screen.dart';

class BusquedaCuidadoresScreen extends StatefulWidget {
  const BusquedaCuidadoresScreen({super.key});

  @override
  State<BusquedaCuidadoresScreen> createState() => _BusquedaCuidadoresScreenState();
}

class _BusquedaCuidadoresScreenState extends State<BusquedaCuidadoresScreen> {
  final _busquedaCtrl = TextEditingController();
  double _maxTarifa = 500;
  double _minCalificacion = 0;
  String _disponibilidad = 'Todos';
  List<UserModel> _resultados = [];

  final List<String> _disponibilidades = ['Todos', 'Lunes a Viernes', 'Fines de semana', 'Tiempo completo'];

  @override
  void initState() {
    super.initState();
    _resultados = AppData.instance.getCuidadores();
  }

  void _buscar() {
    final query = _busquedaCtrl.text.toLowerCase();
    setState(() {
      _resultados = AppData.instance.getCuidadores().where((c) {
        final matchNombre = c.nombre.toLowerCase().contains(query);
        final matchUbicacion = (c.ubicacion ?? '').toLowerCase().contains(query);
        final matchTarifa = (c.tarifa ?? 0) <= _maxTarifa;
        final matchCalif = c.calificacion >= _minCalificacion;
        final matchDisp = _disponibilidad == 'Todos' ||
            (c.disponibilidad ?? '').contains(_disponibilidad.split(' ').first);
        return (query.isEmpty || matchNombre || matchUbicacion) &&
            matchTarifa && matchCalif && matchDisp;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Cuidadores')),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: (_) => _buscar(),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o ubicación...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _mostrarFiltros,
                ),
              ),
            ),
          ),

          // Chips de filtros activos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              if (_disponibilidad != 'Todos')
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(_disponibilidad),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () { setState(() => _disponibilidad = 'Todos'); _buscar(); },
                    backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                  ),
                ),
              if (_maxTarifa < 500)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text('Máx \$${_maxTarifa.toInt()}'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () { setState(() => _maxTarifa = 500); _buscar(); },
                    backgroundColor: Colors.teal.withValues(alpha: 0.1),
                  ),
                ),
              if (_minCalificacion > 0)
                Chip(
                  label: Text('★ ${_minCalificacion.toStringAsFixed(1)}+'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () { setState(() => _minCalificacion = 0); _buscar(); },
                  backgroundColor: Colors.amber.withValues(alpha: 0.1),
                ),
            ]),
          ),
          const SizedBox(height: 4),

          // Resultados
          Expanded(
            child: _resultados.isEmpty
              ? const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No se encontraron cuidadores', style: TextStyle(color: Colors.grey)),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _resultados.length,
                  itemBuilder: (ctx, i) => _CuidadorCard(cuidador: _resultados[i]),
                ),
          ),
        ],
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Disponibilidad'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: _disponibilidades.map((d) =>
                ChoiceChip(
                  label: Text(d),
                  selected: _disponibilidad == d,
                  onSelected: (_) => setLocal(() => _disponibilidad = d),
                  selectedColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                ),
              ).toList()),
              const SizedBox(height: 16),
              Text('Tarifa máxima: \$${_maxTarifa.toInt()}/hr'),
              Slider(
                value: _maxTarifa,
                min: 50, max: 500, divisions: 9,
                onChanged: (v) => setLocal(() => _maxTarifa = v),
                activeColor: const Color(0xFF7C4DFF),
              ),
              const SizedBox(height: 8),
              Text('Calificación mínima: ${_minCalificacion.toStringAsFixed(1)} ★'),
              Slider(
                value: _minCalificacion,
                min: 0, max: 5, divisions: 10,
                onChanged: (v) => setLocal(() => _minCalificacion = v),
                activeColor: Colors.amber,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _buscar();
                  },
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CuidadorCard extends StatelessWidget {
  final UserModel cuidador;
  const _CuidadorCard({required this.cuidador});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                child: Text(
                  cuidador.nombre.isNotEmpty ? cuidador.nombre[0] : '?',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cuidador.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${cuidador.calificacion.toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    Text(cuidador.ubicacion ?? 'N/A', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ]),
                ],
              )),
              Column(children: [
                Text('\$${(cuidador.tarifa ?? 0).toInt()}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                const Text('/hr', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ]),
            const SizedBox(height: 12),
            if (cuidador.experiencia != null)
              Text(cuidador.experiencia!, style: const TextStyle(color: Colors.black87, fontSize: 13)),
            const SizedBox(height: 8),
            if (cuidador.disponibilidad != null)
              Row(children: [
                const Icon(Icons.schedule, size: 14, color: Colors.teal),
                const SizedBox(width: 4),
                Text(cuidador.disponibilidad!, style: const TextStyle(color: Colors.teal, fontSize: 13)),
              ]),
            if (cuidador.certificaciones != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.verified, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Expanded(child: Text(cuidador.certificaciones!,
                  style: const TextStyle(color: Colors.blue, fontSize: 13))),
              ]),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Ver Perfil'),
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PerfilCuidadorScreen(cuidador: cuidador))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Agendar'),
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AgendarCitaScreen(cuidador: cuidador))),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
