# Barrio de Fantasía — iOS Native App

Aplicación nativa para iOS construida con **Swift 6**, **SwiftUI**, **SwiftData** y **Xcode 27.2**, optimizada para los estándares de revisión de la **App Store** de Apple, con arquitectura autónoma (Offline-First) y sincronización con el servidor backend de Barrio de Fantasía.

---

## ⚽ Características Principales

1. **Gestión de Partidos & Convocatorias:**
   - Lista y fichas de partidos (Fútbol 6 / Fútbol 7).
   - Sistema de convocatoria interactivo para apuntarse y ver alineaciones (Equipo A vs Equipo B).
   - Visualización de marcadores y estado del encuentro en tiempo real.

2. **Sistema de Votaciones 24 Horas:**
   - Papeleta digital activa durante las 24 horas posteriores a la finalización del partido.
   - Puntuación táctil (1.0 a 10.0) para cada compañero de pandilla.
   - Elección obligatoria de **MVP del partido** con feedback háptico.
   - Avisos locales preventivos (`UserNotifications`) 2 horas antes del vencimiento para evitar la penalización de -2 pts en Fantasy.

3. **Directorio y Fichas de Jugadores:**
   - Filtros por demarcación oficial: **POR** (Portero), **DEF** (Defensa), **MED** (Centrocampista), **DEL** (Delantero).
   - Estadísticas acumuladas: Partidos jugados, goles, asistencias, MVPs y nota media histórica.
   - Valor de mercado Fantasy actualizado.

4. **Clasificación & Liga Fantasy:**
   - Tabla general de clasificación de equipos con historial de forma (V/E/D).
   - Leaderboard de mánagers Fantasy con puntos semanales, acumulados y control de penalizaciones.
   - Plantilla Fantasy del usuario con visualización de presupuesto.

5. **Vitrina de Trofeos & Logros:**
   - Desbloqueo de insignias por rendimiento (Pichichi de Oro, El Muro Imbatible, Votante Ejemplar, etc.).

---

## 🛠️ Arquitectura Técnica

- **Lenguaje:** Swift 6 con Swift Concurrency estricto (`@MainActor`, `Sendable`, `async/await`).
- **Framework UI:** SwiftUI moderno con patrón MVVM reactivo mediante `@Observable`.
- **Persistencia Local:** SwiftData (`ModelContainer`) con inicialización de datos de prueba (`DemoDataLoader`) para funcionamiento autónomo sin conexión.
- **Sincronización:** `APIService` con sesión HTTP/JSON hacia la API de Barrio de Fantasía.
- **Generación del Proyecto:** XcodeGen (`project.yml`) para configuración reproducible y limpia.
- **Privacidad:** `PrivacyInfo.xcprivacy` y `Info.plist` conforme a directrices de revisión de App Store.

---

## 🚀 Compilación y Ejecución

```bash
# 1. Regenerar el proyecto Xcode con XcodeGen
xcodegen generate

# 2. Compilar con xcodebuild
xcodebuild -project BarrioFantasia.xcodeproj \
           -scheme BarrioFantasia \
           -destination "platform=iOS Simulator,name=iPhone 18 Pro" \
           clean build

# 3. Lanzar en el simulador
xcrun simctl launch booted com.barriofantasia.app
```
