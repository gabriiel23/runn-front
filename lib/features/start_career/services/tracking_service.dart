import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

// ─── Handler del Isolate de segundo plano ─────────────────────────────────────
//
// Este código corre en un Isolate SEPARADO del UI principal.
// @pragma es obligatorio para que Dart lo compile en Release mode.

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(_TrackingTaskHandler());
}

class _TrackingTaskHandler extends TaskHandler {
  double _distanciaKm = 0;
  int _duracionSegs = 0;
  Position? _lastPosition;
  StreamSubscription<Position>? _posSub;

  // Estado para la notificación (actualizado por el stream)
  double _lastSpeed = 0;
  double _lastLat = 0;
  double _lastLng = 0;
  bool _hasPosition = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Iniciamos el stream de GPS con distanceFilter=5
    // El OS solo dispara este evento cuando hay un desplazamiento real >= 5 metros.
    // Esto es MUCHO más confiable que llamar getCurrentPosition cada segundo.
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        // 2 m: el OS dispara el evento continuamente al moverse,
        // garantizando respuesta inmediata desde el primer paso.
        distanceFilter: 2,
      ),
    ).listen(_onNuevaPos, onError: (_) {});
  }

  // ─── Umbrales anti-drift GPS ──────────────────────────────────────────────
  // Velocidad mínima para considerar movimiento real: 0.5 m/s ≈ 1.8 km/h.
  // Cubre senderismo lento sin acumular ruido de GPS estático.
  static const double _kVelocidadMinimaMs = 0.5;

  // Precisión máxima aceptada: 20 m. Bajo techo el GPS suele oscilar entre
  // 10-30 m; ser más estrictos descarta la mayoría de lecturas de interior.
  static const double _kAccuracyMaxima = 20.0;

  // Delta mínimo real para acumular distancia: 3.5 m.
  // Al mantener la última posición aceptada como referencia, acumulamos
  // perfectamente trayectos continuos cortos sin sufrir por drift estático.
  static const double _kDeltaMinimoM = 3.5;

  // Delta máximo: descarta teletransportaciones imposibles (> 200 m en 1 tick).
  static const double _kDeltaMaximoM = 200.0;

  void _onNuevaPos(Position pos) {
    // Filtro 1 — Precisión: ignorar lecturas GPS de baja calidad.
    // Bajo techo la señal es débil y la accuracy puede ser muy alta (malo).
    if (pos.accuracy > _kAccuracyMaxima) return;

    // Filtro 2 — Velocidad mínima: no sumar distancia si el usuario está quieto.
    // CORRECCIÓN CLAVE: Solo aplicamos este filtro si el dispositivo reporta una velocidad mayor a 0.
    // En muchos teléfonos (como TECNO, Xiaomi, etc.) el hardware de GPS no calcula la velocidad en tiempo real
    // y devuelve siempre 0.0 constante, lo que bloqueaba por completo la acumulación de metros.
    if (pos.speed > 0.0 && pos.speed < _kVelocidadMinimaMs) {
      // Aun así actualizamos la última posición para no crear saltos cuando
      // el usuario empiece a moverse de nuevo.
      _lastPosition = pos;
      _lastLat = pos.latitude;
      _lastLng = pos.longitude;
      _lastSpeed = pos.speed;
      _hasPosition = true;
      // Notificamos a la UI la posición actualizada (sin cambiar la distancia)
      FlutterForegroundTask.sendDataToMain({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'speed': pos.speed,
        'distanciaKm': _distanciaKm,
        'duracionSegs': _duracionSegs,
      });
      return;
    }

    if (_lastPosition != null) {
      final delta = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
      // Filtro 3 — Delta mínimo y máximo: acepta solo desplazamientos reales.
      // >= 3.5 m elimina drift residual; < 200 m elimina saltos de GPS imposibles.
      if (delta >= _kDeltaMinimoM && delta < _kDeltaMaximoM) {
        _distanciaKm += delta / 1000;
        
        // CORRECCIÓN CLAVE: Solo actualizamos la posición de referencia cuando el punto es ACEPTADO.
        // Así no perdemos distancias de movimientos continuos pequeños.
        _lastPosition = pos;
        _lastLat = pos.latitude;
        _lastLng = pos.longitude;
      }
    } else {
      // Primer punto válido de la carrera
      _lastPosition = pos;
      _lastLat = pos.latitude;
      _lastLng = pos.longitude;
    }

    _lastSpeed = pos.speed;
    _hasPosition = true;

    // Notificar a la UI inmediatamente cuando hay nueva posición
    FlutterForegroundTask.sendDataToMain({
      'lat': _lastLat,
      'lng': _lastLng,
      'speed': pos.speed,
      'distanciaKm': _distanciaKm,
      'duracionSegs': _duracionSegs,
    });
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // onRepeatEvent solo gestiona el cronómetro y actualiza la notificación.
    // El GPS lo maneja el stream (_posSub) de forma independiente.
    _duracionSegs++;

    final distFmt = _distanciaKm < 1.0
        ? '${(_distanciaKm * 1000).round()} m'
        : '${_distanciaKm.toStringAsFixed(3)} km';
    final velKmh = (_lastSpeed * 3.6).toStringAsFixed(1);
    final minutos = _duracionSegs ~/ 60;
    final segundos = _duracionSegs % 60;
    final tiempoFmt =
        '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';

    FlutterForegroundTask.updateService(
      notificationTitle: 'RUNN — En carrera 🏃',
      notificationText: '$distFmt · $tiempoFmt · $velKmh km/h',
    );

    // Enviar el tiempo actualizado a la UI cada segundo
    if (_hasPosition) {
      FlutterForegroundTask.sendDataToMain({
        'lat': _lastLat,
        'lng': _lastLng,
        'speed': _lastSpeed,
        'distanciaKm': _distanciaKm,
        'duracionSegs': _duracionSegs,
      });
    } else {
      // Aún sin posición GPS — solo enviar el tiempo
      FlutterForegroundTask.sendDataToMain({
        'distanciaKm': _distanciaKm,
        'duracionSegs': _duracionSegs,
      });
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _posSub?.cancel();
    _posSub = null;
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      _distanciaKm = (data['distanciaKm'] as num?)?.toDouble() ?? _distanciaKm;
      _duracionSegs = (data['duracionSegs'] as num?)?.toInt() ?? _duracionSegs;
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/run_active');
  }
}

// ─── API pública del servicio ──────────────────────────────────────────────────

class TrackingService {
  TrackingService._();

  /// Inicializa la configuración del ForegroundTask.
  /// Llamar una vez en main() antes de runApp().
  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'runn_tracking_channel',
        channelName: 'RUNN — Tracking GPS',
        channelDescription: 'Mantiene el GPS activo mientras corres.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000), // cada 1 segundo
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// Inicializa el puerto de comunicación y registra el callback de datos.
  static void addDataCallback(void Function(dynamic) callback) {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(callback);
  }

  /// Elimina el callback de datos registrado.
  static void removeDataCallback(void Function(dynamic) callback) {
    FlutterForegroundTask.removeTaskDataCallback(callback);
  }

  /// Arranca el Foreground Service de GPS.
  static Future<ServiceRequestResult> start() async {
    return FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'RUNN — En carrera 🏃',
      notificationText: '0 m · 00:00 · 0.0 km/h',
      callback: startCallback,
    );
  }

  /// Detiene el servicio de foreground.
  static Future<ServiceRequestResult> stop() async {
    return FlutterForegroundTask.stopService();
  }

  /// Envía el estado actual al isolate (para sincronizar al reanudar).
  static void syncState({
    required double distanciaKm,
    required int duracionSegs,
  }) {
    FlutterForegroundTask.sendDataToTask({
      'distanciaKm': distanciaKm,
      'duracionSegs': duracionSegs,
    });
  }
}
