/// Formatea una distancia en km de forma inteligente:
/// - Si < 1 km → muestra en metros redondeados: "142 m"
/// - Si >= 1 km → muestra en km con 3 decimales: "3.451 km"
///
/// Retorna un record (valor, unidad) para que la UI pueda
/// mostrarlos con estilos diferentes si lo desea.
({String valor, String unidad}) formatDistancia(double km) {
  if (km < 1.0) {
    final metros = (km * 1000).round();
    return (valor: '$metros', unidad: 'm');
  } else {
    return (valor: km.toStringAsFixed(3), unidad: 'km');
  }
}
