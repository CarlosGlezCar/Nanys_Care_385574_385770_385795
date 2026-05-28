// ============================================================
// gestion_usuarios_screen.dart
// Admin: gestionar usuarios (ver, agregar, eliminar)
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Cuidadores'),
            Tab(text: 'Tutores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ListaUsuarios(usuarios: AppData.instance.usuarios, onRefresh: () => setState(() {})),
          _ListaUsuarios(usuarios: AppData.instance.getCuidadores(), onRefresh: () => setState(() {})),
          _ListaUsuarios(usuarios: AppData.instance.getTutores(), onRefresh: () => setState(() {})),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormNuevoUsuario(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar'),
        backgroundColor: const Color(0xFF7C4DFF),
      ),
    );
  }

  void _mostrarFormNuevoUsuario(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String rol = 'cuidador';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx2, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nuevo Usuario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Correo'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
              const SizedBox(height: 12),
              const Text('Rol', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: ['tutor', 'cuidador', 'admin', 'supervisor'].map((r) =>
                ChoiceChip(
                  label: Text(r),
                  selected: rol == r,
                  onSelected: (_) => setLocal(() => rol = r),
                  selectedColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                ),
              ).toList()),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nombreCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                    final nuevo = UserModel(
                      id: AppData.instance.generarId(),
                      nombre: nombreCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text.trim().isEmpty ? '1234' : passCtrl.text.trim(),
                      rol: rol,
                    );
                    AppData.instance.usuarios.add(nuevo);
                    Navigator.pop(ctx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuario creado'), backgroundColor: Colors.green),
                    );
                  },
                  child: const Text('Crear usuario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaUsuarios extends StatelessWidget {
  final List<UserModel> usuarios;
  final VoidCallback onRefresh;
  const _ListaUsuarios({required this.usuarios, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (usuarios.isEmpty) {
      return const Center(child: Text('No hay usuarios', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: usuarios.length,
      itemBuilder: (ctx, i) {
        final u = usuarios[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _rolColor(u.rol).withValues(alpha: 0.15),
              child: Text(u.nombre.isNotEmpty ? u.nombre[0] : '?',
                style: TextStyle(fontWeight: FontWeight.bold, color: _rolColor(u.rol))),
            ),
            title: Text(u.nombre),
            subtitle: Text(u.email),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _rolColor(u.rol).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(u.rol, style: TextStyle(color: _rolColor(u.rol), fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            onLongPress: () => _confirmarEliminar(ctx, u, onRefresh),
          ),
        );
      },
    );
  }

  Color _rolColor(String rol) {
    switch (rol) {
      case 'cuidador': return Colors.teal;
      case 'tutor': return Colors.pink;
      case 'admin': return const Color(0xFF7C4DFF);
      default: return Colors.orange;
    }
  }

  void _confirmarEliminar(BuildContext context, UserModel u, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar a ${u.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              AppData.instance.usuarios.remove(u);
              Navigator.pop(context);
              onRefresh();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
