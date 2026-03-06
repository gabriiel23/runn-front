# RUNN — Documento de Contexto del Proyecto

## ¿Qué es RUNN?

RUNN es una aplicación móvil de running y senderismo orientada a deportistas que buscan no solo registrar su actividad física, sino competir e interactuar con otros corredores de forma innovadora.

Su diferenciador principal es el **Sistema de Territorios**: los usuarios conquistan y disputan zonas geográficas reales simplemente corriendo por ellas, creando una capa de competencia y estrategia sobre el mundo real.

---

# Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Frontend móvil | Flutter |
| Backend | Node.js |
| Mapas | Google Maps / Mapbox |
| Datos geográficos | GeoJSON |
| Wearables | Garmin, Apple Watch, Fitbit, Samsung |

---

# El Diferenciador — Sistema de Territorios

El corazón de RUNN es su sistema de conquista territorial.

### ¿Cómo funciona?

- Cuando un usuario corre por una zona, esa zona pasa a ser su territorio.
- Otro usuario puede disputar ese territorio corriendo por la misma zona.
- Si el retador supera al dueño actual, el territorio cambia de dueño.
- Los territorios pueden conquistarse de forma individual o grupal.
- En modalidad grupal, un grupo acumula territorios en conjunto, compitiendo contra otros grupos.

Cada carrera deja de ser solo entrenamiento: se convierte en una decisión estratégica sobre qué zona defender o atacar.

---

# Módulos de la Aplicación

## 🚀 Onboarding & Auth
Flujo de entrada a la app. Incluye:
- Carrusel de presentación de funciones clave
- Registro
- Inicio de sesión
- Configuración inicial (peso, altura, fecha de nacimiento, objetivo)

---

## 🏠 Home
Dashboard principal con:
- Saludo personalizado
- Estadísticas rápidas (carreras, zonas dominadas, puntos)
- Carrusel de noticias
- Botón principal para iniciar carrera
- Resumen semanal
- Tarjeta motivacional

---

## 🏃 Carrera
Flujo completo de actividad deportiva:

- Selección de modo (correr o senderismo)
- Modalidad (individual o grupal)
- Registro en tiempo real:
  - Tiempo
  - Distancia
  - Velocidad
  - Ritmo
  - Ruta GPS
- Resumen final
- Territorios afectados

---

## 🌍 Territorios
Mapa interactivo que muestra:
- Zonas conquistadas coloreadas por dueño
- Exploración libre del mapa
- Detalle de territorios
- Historial de disputas
- Vista "Mis territorios"

---

## 👥 Comunidad

### Incluye:

**Grupos**
- Crear o unirse a grupos
- Modalidad social o territorial

**Rivales**
- Usuarios que han disputado tus territorios
- Historial de enfrentamientos

**Eventos**
- Eventos oficiales con fecha y ruta sugerida

**Buscar usuarios**
- Encontrar corredores
- Ver perfiles públicos

**Invitar amigos**
- Generar link o código de invitación

---

## 🏆 Retos

Tres categorías:
- Diarios
- Semanales
- Generales

Cada reto incluye:
- Objetivo medible
- Barra de progreso
- Recompensa en puntos

---

## 👤 Perfil

Incluye:
- Estadísticas personales
- Gráficas de progreso
- Insignias desbloqueadas
- Configuración
- Conexión con wearable

---

# Vistas de la Aplicación — V1

## 🚀 Onboarding & Auth (7 vistas)

| Vista | Descripción |
|--------|-------------|
| Splash Screen | Logo RUNN, verifica sesión |
| Onboarding | 3 slides con funciones clave |
| Login | Correo/contraseña o Google/Apple |
| Registro | Creación de cuenta |
| Config. Inicial — Paso 1 | Peso y altura |
| Config. Inicial — Paso 2 | Fecha de nacimiento |
| Config. Inicial — Paso 3 | Selección de objetivo |

---

## 🏠 Home (1 vista)

| Vista | Descripción |
|--------|-------------|
| Home | Dashboard con stats, noticias y botón de carrera |

---

## 🏃 Carrera (5 vistas)

| Vista | Descripción |
|--------|-------------|
| Pre-carrera | Selección de modo y verificación GPS |
| Carrera en curso | Métricas en tiempo real |
| Carrera pausada | Opción continuar o finalizar |
| Resumen de carrera | Mapa + estadísticas completas |
| Territorios afectados | Conquistados o disputados |

---

## 🌍 Territorios (3 vistas)

| Vista | Descripción |
|--------|-------------|
| Mapa de territorios | Mapa interactivo |
| Mis territorios | Lista de zonas propias |
| Detalle de territorio | Dueño, historial y retar |

---

## 👥 Comunidad (11 vistas)

| Vista | Descripción |
|--------|-------------|
| Comunidad (hub) | Acceso general |
| Buscar usuarios | Buscador por nombre |
| Perfil ajeno | Perfil público |
| Lista de grupos | Grupos propios y sugeridos |
| Detalle de grupo | Info y territorios |
| Crear grupo | Formulario completo |
| Rivales | Usuarios frecuentes |
| Detalle de rival | Historial directo |
| Eventos | Lista de eventos |
| Detalle de evento | Info y botón unirse |
| Invitar amigos | Link o código |

---

## 🏆 Retos (2 vistas)

| Vista | Descripción |
|--------|-------------|
| Lista de retos | Tabs por categoría |
| Detalle de reto | Progreso y recompensa |

---

## 👤 Perfil (6 vistas)

| Vista | Descripción |
|--------|-------------|
| Mi perfil | Stats principales |
| Mis estadísticas | Gráficas por período |
| Mis insignias | Logros |
| Configuración | Ajustes |
| Editar perfil | Modificar datos |
| Conectar wearable | Vincular reloj |

---

# Total de Vistas

**35 vistas**

---

# Navegación Principal

Bottom Navigation Bar con 5 módulos:

🏠 Inicio  
👥 Comunidad  
🌍 Territorios  
🏆 Retos  
👤 Perfil  

La carrera no vive en la navegación principal; se inicia desde el botón prominente del Home, reforzando que es una acción y no una sección.

---

# Entidades Principales del Sistema

| Entidad | Descripción |
|----------|-------------|
| Usuario | Persona registrada con stats y configuración |
| Actividad | Carrera o caminata con ruta GeoJSON |
| Territorio | Zona geográfica con dueño |
| Disputa de territorio | Registro histórico de intentos |
| Reto | Desafío con objetivo y recompensa |
| Reto de usuario | Progreso individual en reto |
| Grupo | Conjunto de usuarios |
| Miembro de grupo | Relación usuario-grupo |
| Publicación | Contenido dentro de grupo |
| Insignia | Logro desbloqueable |
| Wearable | Reloj inteligente vinculado |
| Notificación | Aviso generado por eventos |

---