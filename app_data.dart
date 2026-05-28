// ============================================================
// app_data.dart  —  Estado global en memoria (runtime)
// ============================================================

class UserModel {
  String id;
  String nombre;
  String email;
  String password;
  String rol; // 'tutor' | 'cuidador' | 'admin' | 'supervisor'
  String? foto;
  // Campos Cuidador
  String? experiencia;
  String? certificaciones;
  String? disponibilidad;
  double? tarifa;
  double calificacion;
  String? ubicacion;
  // Campos Tutor
  List<String> hijos;
  String? necesidades;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.rol,
    this.foto,
    this.experiencia,
    this.certificaciones,
    this.disponibilidad,
    this.tarifa,
    this.calificacion = 0,
    this.ubicacion,
    this.hijos = const [],
    this.necesidades,
  });
}

class Reserva {
  String id;
  String tutorId;
  String cuidadorId;
  DateTime fecha;
  String hora;
  String estado; // 'pendiente' | 'aceptada' | 'rechazada'
  String notas;

  Reserva({
    required this.id,
    required this.tutorId,
    required this.cuidadorId,
    required this.fecha,
    required this.hora,
    required this.estado,
    this.notas = '',
  });
}

class Resena {
  String id;
  String tutorId;
  String cuidadorId;
  double calificacion;
  String comentario;
  DateTime fecha;
  bool esPrivada; // true = solo visible al cuidador

  Resena({
    required this.id,
    required this.tutorId,
    required this.cuidadorId,
    required this.calificacion,
    required this.comentario,
    required this.fecha,
    this.esPrivada = false,
  });
}

class NotaPrivada {
  String id;
  String cuidadorId;
  String tutorId;
  String nota;
  double calificacion;
  DateTime fecha;

  NotaPrivada({
    required this.id,
    required this.cuidadorId,
    required this.tutorId,
    required this.nota,
    required this.calificacion,
    required this.fecha,
  });
}

// ─── Singleton de datos globales ───────────────────────────
class AppData {
  AppData._();
  static final AppData instance = AppData._();

  UserModel? currentUser;

  final List<UserModel> usuarios = [
    UserModel(
      id: 'u1',
      nombre: 'Ana García',
      email: 'tutor@demo.com',
      password: '1234',
      rol: 'tutor',
      hijos: ['Sofía (4 años)', 'Luis (2 años)'],
      necesidades: 'Cuidado entre semana, mañanas',
      ubicacion: 'CDMX',
    ),
    UserModel(
      id: 'u2',
      nombre: 'María López',
      email: 'cuidador@demo.com',
      password: '1234',
      rol: 'cuidador',
      experiencia: '5 años cuidando niños de 0-8 años',
      certificaciones: 'Primeros auxilios, RCP',
      disponibilidad: 'Lunes a Viernes 7am-5pm',
      tarifa: 120.0,
      calificacion: 4.8,
      ubicacion: 'CDMX',
    ),
    UserModel(
      id: 'u3',
      nombre: 'Admin Sistema',
      email: 'admin@demo.com',
      password: '1234',
      rol: 'admin',
    ),
    UserModel(
      id: 'u4',
      nombre: 'Supervisor Ops',
      email: 'supervisor@demo.com',
      password: '1234',
      rol: 'supervisor',
    ),
    UserModel(
      id: 'u5',
      nombre: 'Laura Martínez',
      email: 'laura@demo.com',
      password: '1234',
      rol: 'cuidador',
      experiencia: '3 años, especializada en bebés',
      certificaciones: 'Estimulación temprana',
      disponibilidad: 'Fines de semana',
      tarifa: 100.0,
      calificacion: 4.5,
      ubicacion: 'CDMX Norte',
    ),
  ];

  final List<Reserva> reservas = [
    Reserva(
      id: 'r1',
      tutorId: 'u1',
      cuidadorId: 'u2',
      fecha: DateTime.now().add(const Duration(days: 2)),
      hora: '09:00',
      estado: 'pendiente',
      notas: 'Cuidar a Sofía y Luis',
    ),
  ];

  final List<Resena> resenas = [
    Resena(
      id: 'res1',
      tutorId: 'u1',
      cuidadorId: 'u2',
      calificacion: 5,
      comentario: 'Excelente cuidadora, muy puntual y cariñosa.',
      fecha: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final List<NotaPrivada> notasPrivadas = [];

  // ── Helpers ──────────────────────────────────────────────
  UserModel? login(String email, String password) {
    try {
      return usuarios.firstWhere(
        (u) => u.email == email && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  List<UserModel> getCuidadores() =>
      usuarios.where((u) => u.rol == 'cuidador').toList();

  List<UserModel> getTutores() =>
      usuarios.where((u) => u.rol == 'tutor').toList();

  List<Reserva> getReservasDeCuidador(String cuidadorId) =>
      reservas.where((r) => r.cuidadorId == cuidadorId).toList();

  List<Reserva> getReservasDeTutor(String tutorId) =>
      reservas.where((r) => r.tutorId == tutorId).toList();

  List<Resena> getResenasDeCuidador(String cuidadorId) =>
      resenas.where((r) => r.cuidadorId == cuidadorId && !r.esPrivada).toList();

  String generarId() => DateTime.now().millisecondsSinceEpoch.toString();
}
