# Contributing to Super Tux War

Thanks for your interest in contributing! This document provides guidelines for contributing code, assets, documentation, and other improvements.

## Table of Contents

- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
- [Asset Guidelines](#asset-guidelines)
- [What We Need](#what-we-need)
- [Pull Request Process](#pull-request-process)

---

## Getting Started

### Prerequisites

- **Godot 4.5.1-stable** (required)
- Git for version control
- Basic familiarity with GDScript (for code contributions)
- Pixel art editor (for asset contributions): Aseprite, LibreSprite, GIMP, etc.

### Quick Start

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/super-tux-war.git
   cd super-tux-war
   ```
3. **Open in Godot**:
   ```bash
   godot --editor --path .
   ```
4. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
5. **Make your changes** and test thoroughly
6. **Commit and push**:
   ```bash
   git add .
   git commit -m "Add your feature"
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request** on GitHub

---

## How to Contribute

### Ways to Contribute

- **Code**: Fix bugs, add features, improve performance
- **Art**: Create sprites, tiles, animations, UI elements
- **Audio**: Compose music, create sound effects
- **Documentation**: Write guides, improve existing docs
- **Level Design**: Create new levels
- **Testing**: Play the game, report bugs, suggest improvements
- **Ideas**: Suggest features, game modes, improvements

### Finding Work

- Check [GitHub Issues](https://github.com/tuxx/super-tux-war/issues) for open tasks
- Look for issues labeled `good first issue` or `help wanted`
- Check the [ROADMAP.md](ROADMAP.md) for planned features
- See [What We Need](#what-we-need) below for specific asset requests

---

## Development Setup

### Running the Game

**In Editor**:
```bash
godot --editor --path .
```

**Run Directly**:
```bash
godot --path .
```

### Project Structure

```
super-tux-war/
├── assets/          # All game assets (sprites, tiles, audio)
├── scenes/          # Scene files (.tscn)
├── scripts/         # GDScript code
│   ├── characters/  # Player & NPC logic
│   ├── core/        # Core systems (event bus, game state, etc.)
│   ├── levels/      # Level management
│   ├── objects/     # Interactive objects
│   └── ui/          # User interface
├── addons/          # Editor plugins
├── docs/            # Documentation
└── project.godot    # Godot project file
```

### Key Systems

- **Event Bus**: `scripts/core/event_bus.gd` - Central event system
- **Game Constants**: `scripts/core/game_constants.gd` - Physics values
- **Character Controller**: `scripts/characters/character_controller.gd` - Main character logic
- **Level Navigation**: `scripts/levels/level_navigation.gd` - AI pathfinding

See the [documentation](README.md) for detailed system explanations.

---

## Coding Guidelines

### GDScript Style

**Follow Godot's official style guide**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html

**Key Points**:

- **Indentation**: Use tabs (not spaces)
- **Naming**:
  - `snake_case` for functions and variables
  - `PascalCase` for classes and enums
  - `UPPER_CASE` for constants
- **Type hints**: Use static typing where possible
  ```gdscript
  var speed: float = 240.0
  func move_character(direction: Vector2) -> void:
  ```
- **Comments**: Use `##` for documentation comments
  ```gdscript
  ## Moves the character in the specified direction.
  func move_character(direction: Vector2) -> void:
  ```

### Code Organization

- Keep functions small and focused
- Use `@export` for designer-configurable values
- Prefer signals over direct function calls for loose coupling
- Use the EventBus for global events
- Add error handling and validation

### Performance

- Avoid `get_node()` calls in loops; cache references in `_ready()`
- Use `@onready` for child node references
- Prefer signals over polling
- Test with multiple characters (7 NPCs) for performance

### Example

```gdscript
extends CharacterBody2D
class_name MyCharacter

## Maximum movement speed in pixels per second
@export var max_speed: float = 240.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("characters")


func _physics_process(delta: float) -> void:
	_update_movement(delta)
	move_and_slide()


func _update_movement(delta: float) -> void:
	# Movement implementation
	pass
```

---

## Asset Guidelines

### General Asset Requirements

- **License**: MIT compatible or original work
- **Attribution**: Include attribution if required by license
- **Format**: Use standard formats (PNG for images, OGG for audio)
- **Style**: Consistent pixel art style, no filtering/antialiasing

### Sprites

**Character Sprites**:
- Designed to fit within 32×32 tile footprint
- Collision ~30×30 px (slightly smaller than tile)
- Pixel art style, no filtering
- PNG format with transparency
- Organize in `assets/characters/[name]/spritesheets/`

**Required Animations**:
- `idle` - Standing still (4-8 frames)
- `run` - Running (4-8 frames)
- `jump` - Jumping (1-2 frames)
- `skid` - Quick-stop pose (1 frame)

**Frame Rate**: 4-8 fps for idle, 8 fps for run

**Example Structure**:
```
assets/characters/tux/
├── spritesheets/
│   ├── idle.png
│   ├── run.png
│   └── jump.png
└── [source files].ase (optional)
```

### Tiles

**Tile Specifications**:
- Exactly **32×32 pixels** (strict requirement)
- Pixel art style
- PNG format
- Clear visual distinction between types (solid, semisolid, hazards)

**Organize by Type**:
```
assets/blocks/
├── solid/
│   ├── stone_01.png
│   ├── wood_01.png
│   └── ...
├── semisolid/
│   └── platform_01.png
├── ice/
│   └── ice_01.png
└── death/
    ├── floor/
    │   └── spikes_01.png
    └── ceiling/
        └── stalactites_01.png
```

### TileSet Integration

After adding tiles:
1. Import into Godot (automatic)
2. Open `assets/tilesets/smw_blocks.tres`
3. Add tile to atlas
4. Configure collision shape (32×32 for solid, thin top edge for semisolid)
5. Set physics layer (0 for solid, 1 for semisolid)

See [Level Design - Tile Layers](level-design/tile-layers.md) for details.

### Audio

**Sound Effects**:
- OGG Vorbis format
- Short duration (< 2 seconds typically)
- Normalized volume
- No clipping

**Music**:
- OGG Vorbis format
- Loopable
- 1-2 minute loops preferred
- Normalized volume

**Organize**:
```
assets/audio/
├── sfx/
│   ├── jump.ogg
│   ├── stomp.ogg
│   └── ...
└── music/
    ├── menu.ogg
    ├── level_01.ogg
    └── ...
```

---

## What We Need

This section lists specific assets and contributions we're looking for.

### 🎨 Needed Art Assets

#### Tile Sets (High Priority)

We need decorative and themed tile sets (32×32 pixels each):

**Themes Needed**:
- **Stones**: Brick, cobblestone, cave rock
- **Wood**: Planks, logs, crates
- **Grass**: Green grass, dirt, flowers
- **Snow/Ice**: Snow blocks, icicles, frozen ground
- **Desert**: Sand, sandstone, cacti
- **Metal**: Steel panels, grates
- **Tech**: Circuit boards, screens, wires
- **Castle**: Stone bricks, banners, torches

**For each theme, we need**:
- Solid blocks (ground/walls)
- Semisolid platforms
- Decorative variants
- Hazards (spikes, etc.)

#### Character Sprites (High Priority)

Current characters need improvement or new characters needed:

**Improvements Needed**:
- **Beasty** (FreeBSD daemon) - Current sprite needs refinement
  - Better pixel art quality
  - More expressive animations
  - Consistent with Tux style
- **Tux** (Linux penguin) - Base sprite is serviceable but needs shading cleanup and snappier animation timing
- **Go Gopher** (Go mascot) - Existing sprite feels flat; needs stronger silhouette, shading, and animation polish

**New Characters Needed**:
- **OpenBSD Fish** (Puffy) - Pufferfish mascot
- **GIMP** (Wilber) - Coyote/dog mascot
- **GNU** (GNU Head) - Wildebeest mascot
- **Rust** (Ferris) - Crab mascot
- **Python** - Snake mascot
- **Other open-source mascots** - Suggest your favorites!

**Requirements for Each Character**:
- Idle animation (4-8 frames)
- Run animation (4-8 frames)
- Jump sprite (1-2 frames)
- Skid sprite (1 frame) for quick-stop animation beats
- Fits within 32×32 tile footprint
- Consistent pixel art style

**Note**: Must be legally permissible. Original art inspired by mascots is preferred over direct copies.

#### UI Elements (Medium Priority)

- Menu backgrounds
- Button states (normal, hover, pressed)
- HUD elements (health bars, score counters)
- Icons for items and power-ups
- Character portraits for selection

#### Objects & Items (Medium Priority)

- Stompboxes (breakable item boxes)
- Power-up items (fish, floppies, sudo)
- Throwable items
- Gravestones (improved variants)
- Environmental objects (trees, rocks, decorations)

#### Visual Effects (Low Priority)

- Particle effects (dust, impact, sparkles)
- Death effects
- Power-up effects
- Jump/land effects

### 🎵 Needed Audio Assets

#### Sound Effects (High Priority)

- **Movement**: Jump, land, slide, run
- **Combat**: Stomp hit, death, respawn
- **Items**: Pickup, power-up activation, throw
- **UI**: Button click, menu navigate, select
- **Ambient**: Wind, water, footsteps

#### Music (High Priority)

- **Menu music** - Upbeat, catchy
- **Level themes** (need 3-5 tracks):
  - Grasslands/basic level
  - Ice/snow level
  - Desert level
  - Castle/dungeon level
  - Fast-paced battle theme
- **Victory/Game Over** - Short stingers

**Style**: Upbeat, retro-inspired (chiptune/8-bit acceptable but not required)

### 📝 Documentation (Medium Priority)

- Character system documentation
- Core systems documentation
- API reference
- Tutorial videos or GIFs
- Translation to other languages

### 🎮 Levels (Medium Priority)

We need more levels! See [Level Design - Getting Started](level-design/getting-started.md).

**Needs**:
- Small arenas (good for 2-4 players)
- Medium arenas (good for 4-8 players)
- Themed levels (ice, desert, castle, etc.)
- Vertical levels (emphasis on platforms and jumping)
- Horizontal levels (emphasis on running and spacing)

### 🐛 Testing & Bug Reports (Always Welcome)

- Play the game and report bugs
- Test on different platforms (Linux, Windows, macOS)
- Performance testing (especially with 7+ NPCs)
- Multiplayer testing (when available)

---

## Pull Request Process

### Before Submitting

1. **Test thoroughly**:
   - Run the game and verify your changes work
   - Test with multiple characters (1 player + 7 NPCs)
   - Check for console errors
   - Test on different levels if applicable

2. **Follow style guidelines**:
   - Code follows GDScript style guide
   - Assets meet specifications (32×32 tiles, etc.)
   - Documentation is clear and well-formatted

3. **Keep PRs focused**:
   - One feature or fix per PR
   - Small, reviewable changes
   - Clear, descriptive commits

### PR Checklist

- [ ] Code follows GDScript style guidelines
- [ ] All new code has type hints
- [ ] Documentation is updated (if applicable)
- [ ] Assets meet specifications (size, format, style)
- [ ] Attribution is included (if using external assets)
- [ ] No linter errors or warnings
- [ ] Tested thoroughly in-game
- [ ] Commit messages are clear and descriptive

### PR Description Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Asset addition/improvement
- [ ] Performance improvement
- [ ] Refactoring

## Testing
How was this tested?

## Screenshots/Video
(If applicable)

## Related Issues
Fixes #123, relates to #456
```

### Review Process

1. **Automated checks**: Ensure CI passes (if configured)
2. **Code review**: Maintainers will review your code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged
5. **Thanks!** You'll be credited in the contributors list

---

## Questions?

- **GitHub Discussions**: https://github.com/tuxx/super-tux-war/discussions
- **Issues**: https://github.com/tuxx/super-tux-war/issues

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

**For Code**: Original work licensed under MIT  
**For Assets**: Original work or MIT-compatible licensed assets with proper attribution

See [LICENSE](../LICENSE) for details.

---

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- In-game credits (planned)
- Release notes for significant contributions

Thank you for contributing to Super Tux War! 🎮🐧
