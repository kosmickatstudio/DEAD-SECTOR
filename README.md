# DEAD SECTOR

Original 2D survival-horror action game built in Godot 4.

## Current build

**Vertical Slice:** Mission 01 — The Broadcast

The project is designed around compact authored missions, diagonal-down environments, scarce ammunition, moving reticle headshots, melee fallback, environmental interaction, evidence collection, checkpoints, and character-specific systems.

### Implemented foundation

- Godot 4 project structure with Android-first 720×1280 layout
- Mission 01 gameplay loop and authored environment rendering
- Original Mara Voss player design
- Enemy ecosystem foundation: Hollow, Listener, Crawler, Brute
- Firearm, reload, melee, health, pickups, critical headshots
- Evidence / transmitter / extraction objective chain
- Persistent save system and data-driven campaign map
- 36-mission campaign content plan
- Touch control overlay for mobile
- Android export preset
- GitHub Actions Godot validation
- Original SVG production art assets for Mara Voss and Hollow

## Building

Open the project in Godot 4.7.x. The CI pipeline validates the project headlessly on every push to `main`.

For desktop Android export, Godot currently recommends OpenJDK 17 and an Android SDK configured in Editor Settings. The Android editor can also export directly on supported Android devices. See the official Godot Android export documentation before creating a release-signed build.

## IP

DEAD SECTOR is an original work. It is inspired by the design principles of classic mobile survival-horror games, but uses its own story, characters, environments, enemies, code, art, and audio direction.
