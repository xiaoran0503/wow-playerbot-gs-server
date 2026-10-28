# TomTom

🌐 [Versión en español](README.md)

Navigation addon for World of Warcraft 3.3.5a: route arrow ("crazy arrow"),
minimap and world map waypoints, cursor/player coordinates, and the `/way`
command. This repository is a fork of Cladhaire's original TomTom
(r240-release), with Spanish localization and additional improvements.

**Current maintainer: WarCrafted** (<https://portal.warcrafted.com/>). See
[CREDITS.md](CREDITS.md) for full attribution, including the original
project's.

## Questie integration

TomTom works alongside [Questie](https://github.com/warcrafted-server/Questie)
for quest tracking. When Questie is installed:

- The "Set TomTom Target" buttons in Questie's quest tracker, quest menu and
  search results automatically create TomTom waypoints.
- Questie's AutoRoute moves the TomTom arrow to the next objective for you.
- The arrow shows the quest name alongside the objective name (see below).
- Completing or abandoning a quest removes the matching waypoint.

No setup needed: the integration activates automatically once Questie is
loaded. To turn off the quest name on the arrow, there's an option under
`/tomtom` → Arrow → "Show quest name".

## Installation

1. Copy this folder to `Interface/AddOns/TomTom` in your WoW client.
2. Enable the addon on the character selection screen.
3. Optional: also install [Questie](https://github.com/warcrafted-server/Questie)
   for quest tracking.

## Commands

| Command | Function |
|---|---|
| `/way <x> <y> [description]` | Adds a waypoint in the current zone |
| `/way <zone> <x> <y> [description]` | Adds a waypoint in another zone |
| `/way reset all` | Removes all waypoints |
| `/way reset <zone>` | Removes waypoints in a zone |
| `/cway` or `/closestway` | Points the arrow at the closest waypoint |
| `/wayb` or `/wayback` | Creates a waypoint at your current position |
| `/tomtom` | Opens the options panel |

## Languages

Spanish, English, German, Russian, Simplified Chinese and Traditional
Chinese. See [CHANGELOG.md](CHANGELOG.md) for per-language coverage.

## License

This is a fork of TomTom (Cladhaire). The original package doesn't include
an explicit license, so this repository doesn't create a new one to replace
it: see [LICENSE](LICENSE) for what's known and unknown about the original
project, and [CREDITS.md](CREDITS.md) for attribution. Each bundled
third-party library keeps its own license.

## Development docs

See [CONTRIBUTING.md](CONTRIBUTING.md) if you're contributing changes to this repository.
