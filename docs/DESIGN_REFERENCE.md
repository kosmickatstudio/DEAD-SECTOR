# DEAD SECTOR design reference

## Research decisions

DEAD SECTOR takes the useful structural lessons from classic Java-era mobile survival-horror without reproducing protected characters, story, maps, dialogue, art, or code.

The target design language is:

1. Diagonal-down 2D exploration with compact authored rooms and corridors.
2. Survival pressure from scarce ammunition, health, and checkpoints.
3. Aiming as a deliberate skill rather than a pure twin-stick spray mechanic.
4. Puzzles built from keys, evidence, switches, item combinations, and environmental clues.
5. Character roles that materially change how a mission is solved.
6. Short missions that escalate through scripted encounters, special enemies, and bosses.
7. A mobile interface that keeps the screen readable while preserving the horror atmosphere.

## Original universe

**Mara Voss** is a former emergency-response operative whose field training emphasizes firearms, improvisation, and physical problem solving.

**Elias Kane** is an investigative documentarian whose camera and evidence toolkit unlocks alternate information paths, access clues, and story outcomes.

**HELIX-9** was created as a neural-repair treatment. The Helix Event occurs when the treatment begins rewriting memory and motor pathways instead of repairing them.

## Visual target

Dark urban realism, wet reflective floors, sodium-vapor or emergency lighting, hard silhouettes, practical industrial architecture, readable character poses, and strong local contrast around interactable objects. The game should feel authored and illustrated rather than procedural or minimalist.

## Quality gate

A mission is not considered shippable merely because it runs. It must pass:

- gameplay loop test
- input test on touch and keyboard
- collision and navigation test
- headshot / critical-hit test
- objective-state test
- save / checkpoint test
- performance test on target Android hardware
- visual consistency test
- audio and haptic pass
