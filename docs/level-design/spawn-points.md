# Spawn Points

Spawn points control where players and NPCs appear in the level. This guide covers the spawn system, best practices for placement, and configuration options.

## Overview

The spawn system manages:
- **Initial spawn** when the level loads
- **Respawn** after character death (2 second delay)
- **Spawn distribution** to avoid clustering
- **Role filtering** (player vs NPC spawns)

## Spawn Point Basics

### SpawnPoint Scene

**Path**: `res://scenes/objects/spawn_point.tscn`  
**Script**: `res://scripts/levels/spawn_point.gd`  
**Type**: Marker2D with custom properties

### Adding Spawn Points

1. Select **SpawnManager** in your level's scene tree
2. Scene → Instantiate Child Scene
3. Choose `res://scenes/objects/spawn_point.tscn`
4. Position the spawn point on a platform
5. Repeat for multiple spawn points (recommend 4-8)

### Spawn Point Properties

Configure in the Inspector when a SpawnPoint is selected:

```gdscript
@export var allowed: AllowedRole = AllowedRole.ANY
@export var radius: float = 16.0
@export var weight: int = 1
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| **allowed** | Enum | ANY | Who can spawn here (ANY, PLAYER, NPC) |
| **radius** | float | 16.0 | Visual indicator radius (editor only) |
| **weight** | int | 1 | Spawn preference (not currently used) |

### AllowedRole Options

- **ANY**: Player and NPCs can spawn here (default, recommended)
- **PLAYER**: Only the player can spawn here
- **NPC**: Only NPCs can spawn here

**Best Practice**: Use **ANY** for most spawn points to maximize flexibility.

## Spawn Manager

The SpawnManager node orchestrates character spawning.

**Script**: `res://scripts/levels/spawn_manager.gd`  
**Location**: Child of level root, parent of all SpawnPoint nodes

### What It Does

1. **Collects spawn points** at level start
2. **Spawns player character** at a spawn point
3. **Spawns NPCs** based on game settings (CPU count)
4. **Assigns spawn colors** to CPUs for differentiation
5. **Handles respawning** when characters die

### Spawn Distribution

The system intelligently distributes spawns to avoid clustering:

**Safe Spawn Distance**: 128px (4 tiles)

When selecting a spawn point, the system:
1. Filters by `allowed` role (PLAYER/NPC/ANY)
2. Excludes points too close to living characters
3. Excludes the last spawn point used (for respawns)
4. Randomly picks from safe spawn points
5. Falls back to furthest point if no safe points available

This ensures characters don't spawn on top of each other.

## Spawn Point Placement

### Recommended Count

| Level Size | Min Spawns | Recommended | Max Spawns |
|------------|------------|-------------|------------|
| Small (20×15 tiles) | 3 | 4-5 | 6 |
| Medium (40×22 tiles) | 4 | 6-8 | 10 |
| Large (60×30 tiles) | 6 | 8-12 | 16 |

**Rule of Thumb**: 1 spawn point per ~200 tiles of playable area.

### Placement Best Practices

✅ **Good Placement**:
- **Spread throughout level** - Use entire level space
- **Different heights** - Varied vertical positions
- **On stable ground** - Solid or semisolid platforms
- **Away from hazards** - Not near death tiles/pits
- **Safe landing spots** - At least 2 tiles of headroom
- **Combat neutral** - No inherent advantage/disadvantage

❌ **Bad Placement**:
- **Clustered together** - Creates spawn camping
- **Same height** - Reduces vertical variety
- **Floating in air** - Characters will fall (bad UX)
- **Near death zones** - Easy to die immediately after spawn
- **In corners** - Hard to escape from
- **Unequal distribution** - Some areas have all spawns

### Example Layouts

#### Small Arena (4 spawns)

```
████████████████████████████████
█                              █
█   S1                     S2  █
█                              █
█         ████████             █
█                              █
█   S3                     S4  █
████████████████████████████████
```

- 4 corners for even distribution
- All on same level (floor)

#### Multi-Tier Arena (6 spawns)

```
████████████████████████████████
█                              █
█      S1         S2           █  ← Top platforms
█   ▬▬▬▬▬      ▬▬▬▬▬           █
█                              █
█  S3      ████████       S4   █  ← Mid platform
█                              █
█      S5             S6       █  ← Floor level
████████████████████████████████
```

- Multiple heights for vertical variety
- Spread across horizontal space

#### Complex Arena (8 spawns)

```
█   S1             S2          █
█      ▬▬▬▬    ▬▬▬▬            █  ← High semisolid
█                              █
█ S3       S4      S5      S6  █  ← Mid solid
█     ████    ████    ████     █
█                              █
█       S7             S8      █  ← Floor
████████████████████████████████
```

- Max distribution across 3 height levels
- Ensures no clustering even with 8 players

## Spawn Behavior

### Initial Spawn

When a level loads:

1. **Player spawns first**
   - Picks random spawn point with role = PLAYER or ANY
   - Loads selected character skin (default: Tux)

2. **NPCs spawn sequentially**
   - Number based on GameSettings (default: 1 CPU)
   - Each picks different spawn point
   - Loads selected CPU character skin (default: Beasty)
   - Each gets unique color tint (cycling through color palette)

3. **Position validation**
   - System tracks occupied positions
   - Each new spawn avoids already-occupied points
   - Minimum distance: 128px between spawns

### Respawn After Death

When a character dies:

1. **Gravestone spawns** at death location
2. **2 second delay** before respawn
3. **Select new spawn point**:
   - Avoids last spawn point used
   - Avoids points near living characters
   - Prefers safe distance (128px minimum)
4. **Character respawns** at selected point
5. **Full health/state restored**

### NPC Color Tinting

NPCs are automatically tinted to distinguish them visually:

**CPU Color Palette**:
```gdscript
const CPU_COLORS := [
	Color(1.0, 1.0, 1.0),      # 0: White (default)
	Color(0.2, 0.2, 0.2),      # 1: Dark Gray
	Color(0.3, 0.3, 1.0),      # 2: Blue
	Color(0.3, 1.0, 0.3),      # 3: Green
	Color(1.0, 1.0, 0.3),      # 4: Yellow
	Color(1.0, 0.5, 0.0),      # 5: Orange
	Color(0.8, 0.3, 1.0),      # 6: Purple
	Color(0.3, 1.0, 1.0),      # 7: Cyan
]
```

With 7 CPUs, each gets a different color for easy identification.

## Configuration

### Game Settings

The number of NPCs is controlled by **GameSettings** (autoload singleton):

**Script**: `res://scripts/core/game_settings.gd`

**Relevant Functions**:
```gdscript
GameSettings.get_cpu_count()      # Returns number of NPCs to spawn
GameSettings.get_player_character()  # Returns player character name
GameSettings.get_cpu_character()     # Returns CPU character name
```

Default: 1 CPU character

**To test with more NPCs**:
1. Run the game (F5)
2. Click the CPU character on the right
3. Click `+` till you get the number of CPU's you want
4. Start the game

### Spawn Point Configuration

Most spawn points should use default settings:
- **Allowed**: ANY
- **Radius**: 16.0
- **Weight**: 1

**When to use restricted roles**:

**PLAYER-only spawns**:
- Designated "safe" starting positions
- Special player-only areas (rare)
- Asymmetric game modes (future)

**NPC-only spawns**:
- Separate NPC spawn zones
- Keep NPCs away from player start
- Asymmetric game modes (future)

**Recommendation**: Stick with **ANY** unless you have a specific design reason.

## Debugging Spawn System

### Visual Indicators

In the editor, spawn points show as circular markers. Position them carefully on platforms.

### Testing Spawns

**Quick Test** (1 player + 1 NPC):
1. Run current scene (F6)
2. Observe where player and NPC spawn
3. Let player die and watch respawn

**Full Test** (7 NPCs):
1. Run game (F5)
2. Click CPU character -> CPU Count: 7
3. Start game with your level
4. Check spawn distribution
5. Let characters die and watch respawn patterns

### Common Issues

**Characters spawn in mid-air and fall**:
- Move spawn points onto platforms (solid or semisolid)
- Spawn points should be on/slightly above ground level

**All spawns in same area**:
- Spread spawn points throughout the level
- Check that spawn points aren't clustered

**Player/NPC doesn't spawn**:
- Ensure at least 1 spawn point has allowed = ANY or matching role
- Check SpawnManager is present with spawn point children
- Check console for errors

**NPCs spawn too close together**:
- Add more spawn points (4-8 recommended)
- Spread them at least 4 tiles (128px) apart

**Spawn point "hidden" by tiles**:
- Spawn points use z-index of Marker2D (renders in editor)
- In game, they're invisible (as intended)

## Advanced: Custom Spawn Logic

### Modify Spawn Selection

To customize spawn point selection, edit `spawn_manager.gd`:

**Key Function**:
```gdscript
func _pick_point_for_role(
    role: String, 
    avoid_point: SpawnPoint, 
    occupied_positions: Array[Vector2]
) -> SpawnPoint
```

**Current Logic**:
1. Filter by allowed role
2. Remove avoid_point (last used spawn)
3. Calculate safe candidates (not near other characters)
4. If safe candidates exist, pick random
5. If no safe candidates, pick furthest from all characters

**Customization Ideas**:
- Weighted random selection (use `weight` property)
- Prefer higher/lower spawn points
- Team-based spawn zones
- Cycle through spawn points sequentially

### Spawn Events

The system uses EventBus for spawn notifications:

**Events** (check `event_bus.gd`):
```gdscript
# Listen for character spawns
EventBus.character_spawned.connect(_on_character_spawned)

# Listen for character deaths
EventBus.character_died.connect(_on_character_died)
```

### Character Selection

To change which characters spawn, modify `spawn_manager.gd`:

```gdscript
func _initial_spawn() -> void:
    var player_character := "tux"
    var cpu_character := "beasty"
    if has_node("/root/GameSettings"):
        player_character = GameSettings.get_player_character()
        cpu_character = GameSettings.get_cpu_character()
    # ...
```

Available characters:
- `"tux"` - Tux the penguin
- `"beasty"` - FreeBSD daemon
- `"gopher"` - Go gopher

## Related Topics

- **[Getting Started](getting-started.md)** - Includes spawn point setup
- **[Tile Layers](tile-layers.md)** - Understanding platforms for spawn placement
- **[Navigation Graph](navigation-graph.md)** - How NPCs pathfind between spawns
- [spawn_manager.gd](../../scripts/levels/spawn_manager.gd) - Spawn system code
- [spawn_point.gd](../../scripts/levels/spawn_point.gd) - Spawn point class

---

**Next**: [Level Thumbnails →](level-thumbnails.md)

