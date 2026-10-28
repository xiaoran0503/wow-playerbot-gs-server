# Contribuir a TomTom

Fork de TomTom (Cladhaire, r240-release) para WoW 3.3.5a (Interface 30300), mantenido por
WarCrafted. Addon Lua/XML sin build: se juega copiando la carpeta a `Interface/AddOns/TomTom`.

## Estructura

- `TomTom.lua`: núcleo, opciones (AceDB), waypoints por zona, comando `/way`.
- `TomTom_Waypoints.lua`: iconos de minimapa/mapa del mundo, no llamar directo (usar
  `AddZWaypoint`/`RemoveWaypoint` de `TomTom.lua`).
- `TomTom_CrazyArrow.lua`: flecha de ruta.
- `TomTom_POIIntegration.lua`: engancha los POI de misión de Blizzard.
- `TomTom_Config.lua`: panel de opciones (AceConfig).
- `TomTom_Corpse.lua`: flecha al cadáver.
- `Localization.<locale>.lua`: tablas `L[...]`; `enUS` vacía a propósito (fallback = clave).
- `libs/`: Astrolabe, Ace3, LibStub, CallbackHandler, LibDataBroker — de terceros, no editar.

## Contrato con Questie — no romper

Questie (`../Questie`, mismo servidor) depende de esta API exacta:

- `TomTom:AddZWaypoint(c, z, x, y, title, persistent, minimap, world, custom_callbacks, silent, crazy)`:
  firma y orden fijos. `waypoints[uid].title/.zone/.coord` son los campos que Questie compara para
  reconocer su propio waypoint — no renombrar ni quitar.
  `TomTom:IsValidWaypoint`/`RemoveWaypoint`, `TomTom.db.profile.mapcoords.*`,
  `TomTom:ShowHideWorldCoords` (Questie la enlaza con `hooksecurefunc`) y el frame global
  `TomTomWorldFrame` (Questie reemplaza su `OnUpdate`).
- Antes de tocar cualquiera de estos símbolos, comprueba el uso real en
  `../Questie/Compat/Map.lua` y `../Questie/Modules/Tracker/TrackerUtils.lua`.
- Campos nuevos en `waypoints[uid]` (p.ej. `questId`) son seguros: añadir, no reemplazar.

## Convenciones

- Indentación con tabs (como el original); comentarios en inglés si están junto a código ya en
  inglés, en español en ficheros nuevos.
- Toda cadena visible al jugador va envuelta en `L["..."]`; añadir la clave a
  `Localization.enUS.lua` (aunque quede igual al texto) y a `Localization.esES.lua`.
- Versión real del addon en `TomTom.toc` (`## Version:`), no `wowi:revision`.
- Este proyecto sigue la política UPSTREAM (fork): no se asigna una licencia propia al conjunto
  ni a los ficheros nuevos, dado que no hay una licencia original confirmada que reemplazar; ver
  LICENSE y CREDITS.md antes de tocar el aviso de licencia.

## Flujo de trabajo

- Cada cambio: commit propio, mensaje en español, y push a `main`
  (`https://github.com/warcrafted-server/TomTom`).
- Versionado SemVer propio en el `.toc` y tag `vX.Y.Z`; v1.0.0 = r240 original sin cambios.
  Entrada correspondiente en `CHANGELOG.md` en cada release.
- Actualiza `README.md`/`README.en.md` y `CHANGELOG.md` en el mismo commit que el cambio que
  documentan, no al final de la tarea.
- Antes de modificar algo que Questie usa, probar que Questie lo sigue usando igual (ver sección
  anterior).
