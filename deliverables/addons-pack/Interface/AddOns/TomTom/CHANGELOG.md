# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).
Versionado [SemVer](https://semver.org/lang/es/) propio de este fork.

## [Sin publicar]

### Corregido
- LICENSE reescrito siguiendo la política UPSTREAM (fork) en vez de asignar
  MIT a las modificaciones sin base para ello. Se añade CREDITS.md.
- README, CREDITS.md y LICENSE identifican explícitamente a WarCrafted como
  mantenedor actual y exigen conservar esa atribución en cualquier
  redistribución o fork de este repositorio.

## [1.3.0] - 2026-09-27

### Añadido
- Opción "Unidad de distancia" (yardas/metros) en Opciones generales.
  Afecta a la flecha de ruta, su feed LDB y los tooltips de waypoint.
  Conversión con la yarda internacional exacta (1 yd = 0.9144 m); es
  solo de visualización, el juego sigue midiendo en yardas
  internamente.

## [1.2.1] - 2026-09-27

### Corregido
- `Localization.esES.lua` no estaba registrado en `TomTom.toc`, así que
  WoW nunca lo cargaba: la traducción al español de la v1.1.0 no
  llegaba a aplicarse en el juego.
- Ese mismo fichero sobreescribía `TomTomLocals` sin comprobar
  `GetLocale()`, a diferencia del resto de idiomas. De haberse cargado,
  habría roto alemán, ruso y los dos chinos para cualquier jugador,
  fuera cual fuera su idioma de cliente.

## [1.2.0] - 2026-09-27

### Añadido
- La flecha de ruta muestra el nombre de la misión cuando el waypoint
  activo lo puso Questie para una misión en seguimiento (opción
  "Mostrar nombre de la misión", activada por defecto). El tooltip del
  waypoint también lo incluye.
- `/way` acepta la coma como separador decimal (`45,2` además de
  `45.2`).
- El panel de opciones muestra la versión real del addon.
- Aviso en la opción de waypoints automáticos de misión si Questie
  está cargado: su AutoRoute ya hace lo mismo y activar ambas hace que
  la flecha se dispute el waypoint activo.

## [1.1.0] - 2026-09-27

### Añadido
- Traducción completa al español (esES/esMX), 148 cadenas.

### Corregido
- `WaypointExists` devolvía tras la primera iteración del bucle.
- `AddZWaypoint` fallaba con `custom_callbacks` sin tabla `.distance`.
- `CHAT_MSG_ADDON` podía recibir datos nulos y romper con un waypoint
  mal formado.
- `Block_OnClick` fallaba al pulsar el bloque de coordenadas sin
  posición del jugador (p. ej. dentro de una instancia).
- `ShowWaypoint` leía campos inexistentes (`point.data.*`).
- El menú "eliminar waypoints de esta zona" de la flecha podía indexar
  un waypoint ya eliminado.
- `Minimap_OnUpdate` compartía el contador de throttle entre todos los
  iconos de waypoint en vez de llevar uno por icono.
- Variables globales sin declarar (`cell`, `numObjectives`) que
  contaminaban `_G`.
- Autor duplicado y versión fija en `TomTom.toc`; ahora refleja la
  versión real del addon.

## [1.0.0] - 2026-09-27

Punto de partida de este fork: TomTom r240-release (Cladhaire), sin modificaciones,
para WoW 3.3.5a (Interface 30300).

### Idiomas incluidos
- Alemán (deDE): 71 cadenas
- Chino simplificado (zhCN): 114 cadenas
- Chino tradicional (zhTW): 114 cadenas
- Ruso (ruRU): 118 cadenas
- Inglés (enUS): fallback vacío (usa la clave como texto)

[Sin publicar]: https://github.com/warcrafted-server/TomTom/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/warcrafted-server/TomTom/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/warcrafted-server/TomTom/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/warcrafted-server/TomTom/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/warcrafted-server/TomTom/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/warcrafted-server/TomTom/releases/tag/v1.0.0
