# Navigation Graph

The navigation graph is an AI pathfinding system that analyzes your level's tile layout and builds a network of nodes and edges for NPC movement. Understanding how it works helps you design levels that NPCs can navigate effectively.

## Overview

**Purpose**: Enable intelligent NPC movement through complex 2D platformer levels

**What it does**:
- Analyzes TileMapLayer nodes to find walkable surfaces
- Creates navigation nodes on platforms
- Builds edges for walking, jumping, and dropping
- Provides pathfinding data for AI controllers
- Visualizes navigation graph for debugging

**Script**: `res://scripts/levels/level_navigation.gd`  
**Class**: `LevelNavigation` (attached to level root Node2D)

## How It Works

<img width="1215" height="643" src="https://github.com/user-attachments/assets/3cd3d221-01a5-45e2-ae2f-ba6e5bad45ac" />


### Graph Building Process

When a level loads, the navigation system:

1. **Collects Tiles**: Scans GroundTileMap (solid) and SemisolidTileMap
2. **Detects Borders**: Identifies solid perimeter walls (optional optimization)
3. **Creates Nodes**: Places navigation nodes on walkable surfaces
4. **Groups Platforms**: Clusters nodes into platform segments
5. **Builds Walk Edges**: Connects adjacent nodes on same platform
6. **Builds Drop Edges**: Connects semisolid platform edges to lower platforms
7. **Builds Jump Edges**: Physics-simulated jump arcs between platforms

The result is a directed graph that NPCs use for pathfinding.

## Navigation Nodes

### Node Creation

**Nodes are placed on**:
- **Solid tiles** (GroundTileMap): Top surface where there's no tile above
- **Semisolid tiles** (SemisolidTileMap): All semisolid platform positions

**Node properties**:
```gdscript
class NodeEntry:
	var id: int               # Unique node ID
	var cell: Vector2i        # Tile coordinate
	var position: Vector2     # World position (top-center of tile)
	var type: String          # "solid" or "semisolid"
	var platform_id: int      # Which platform this node belongs to
	var is_edge: bool         # True if at edge of platform
```

### Node Positioning

Nodes are positioned at the **top-center** of tiles:

```
      ╔═ Node position (top-center)
      ▼
    [===]  ← Tile (32×32)
```

This represents where a character would stand on the tile.

### Platform Grouping

Contiguous nodes on the same row with the same type form a **platform**:

```
Node1 - Node2 - Node3 - Node4    ← Platform 0 (solid)
████████████████████████

    Node5 - Node6                ← Platform 1 (semisolid)
    ▬▬▬▬▬▬▬▬▬▬
```

**Platform properties**:
- `platform_id`: Unique identifier
- `type`: "solid" or "semisolid"
- `y`: Row coordinate
- `nodes`: Array of nodes in this platform

Nodes at the **start or end** of a platform are marked as `is_edge = true` (important for jump edges).

## Navigation Edges

Edges connect nodes and represent movement possibilities.

### Edge Types

| Type | Color | Description |
|------|-------|-------------|
| **Walk** | Green | Horizontal movement between adjacent nodes |
| **Jump** | Cyan | Physics-simulated jump arcs |
| **Drop** | Orange | Falling from semisolid platform edges |

### Walk Edges

**Created between**:
- Nodes on the same platform
- Horizontally adjacent (1 tile apart)
- Same vertical position (±1px tolerance)

```
Node1 ━━━━━━> Node2  (walk edge)
█████████████████
```

**Movement**: Simple horizontal walking

### Drop Edges

**Created from**:
- Semisolid platform edge nodes
- Downward to any solid/semisolid node below
- Maximum depth: 256 tiles

```
Node1 (semisolid edge)
▬▬▬▬▬
  ┃
  ┃ (drop edge)
  ┃
  ▼
Node2
█████
```

**Movement**: Characters drop through semisolid platforms (Down+Jump action)

### Jump Edges

**Most complex edge type** - Uses physics simulation to verify feasibility.

**Created between**:
- Nodes on different platforms
- Within jump distance (configurable)
- Where jump arc doesn't collide with obstacles

**Jump Constraints**:
```gdscript
@export var max_jump_up_tiles: int = 3       # Max vertical jump (96px)
@export var max_jump_horizontal_tiles: int = 4  # Max horizontal jump (128px)
```

**Jump Rules**:
1. **Target not below** start (must be same height or higher, with small tolerance)
2. **Within horizontal range** (≤ 128px by default)
3. **Within vertical range** (≤ 96px up by default)
4. **Solvable arc**: Can reach target with jump physics
5. **Velocity feasible**: Horizontal speed ≤ max run speed + cushion
6. **Collision-free**: Jump arc doesn't hit solid tiles

**Jump Edge Data**:
```gdscript
{
	"from": node_id,
	"to": target_id,
	"type": "jump",
	"points": [Vector2, ...],  # Jump arc path
	"cost": float,              # Path length
	"meta": {
		"time": float,          # Time to complete jump
		"vx": float             # Required horizontal velocity
	}
}
```

### Jump Arc Simulation

<img width="1215" height="636" src="https://github.com/user-attachments/assets/72ef6dfe-b375-4c3d-8b7d-4786632d63b6" />


The system solves jump arcs using real game physics:

**Physics Constants** (from GameConstants):
- **Jump Velocity**: -540 px/s (upward)
- **Gravity**: 1440 px/s² (downward)
- **Max Run Speed**: 330 px/s (horizontal)

**Process**:
1. Calculate jump time using projectile motion equation
2. Compute required horizontal velocity
3. Simulate arc with small timesteps (1/120s)
4. Check each arc point for solid tile collision
5. Verify landing within tolerance of target

This ensures NPCs only attempt jumps that are actually possible with the game's physics.

## Debug Visualization

The navigation system includes debug drawing for development.

### Enable Debug View

**In Editor**:
1. Select the level's root node (TileMapLevel)
2. In Inspector, check:
   - **Debug Draw Graph**: Shows nodes, edges, platforms
   - **Debug Draw Jump Arcs**: Shows jump arc paths

**At Runtime**:
- Debug settings persist via ProjectSettings
- Toggle debug view in dev menu (F11 and F12)

### Visual Elements

**Nodes**:
- **Solid nodes**: Yellow circles
- **Semisolid nodes**: Pink circles
- **Edge nodes**: Larger radius (5px vs 3px)

**Edges**:
- **Walk edges**: Green lines
- **Drop edges**: Orange lines
- **Jump edges**: Cyan polylines (arc paths)

**Platforms**:
- **Solid platforms**: Blue transparent rectangles
- **Semisolid platforms**: Green transparent rectangles

### Interpreting the Graph

Good navigation graph:
- Nodes on all reachable platforms
- Walk edges connecting platform nodes
- Jump edges between nearby platforms
- Drop edges from semisolid edges
- No isolated/unreachable nodes

Bad navigation graph:
- Missing nodes on platforms
- No jump edges between platforms
- Isolated node clusters
- Jump edges colliding with geometry

## Configuration

### Adjusting Jump Limits

Edit level root node properties in Inspector:

```gdscript
@export var max_jump_up_tiles: int = 3
@export var max_jump_horizontal_tiles: int = 4
```

**Increase values**:
- Allows NPCs to attempt longer/higher jumps
- Increases graph building time (more edge checks)
- May enable unrealistic jumps if too high

**Decrease values**:
- Restricts NPC movement to shorter jumps
- Faster graph building
- May make some platforms unreachable

**Recommended**:
- Keep at defaults (3 up, 4 horizontal)
- Matches character physics capabilities
- Tested and balanced

### Physics Constants

Jump simulation uses GameConstants:

```gdscript
const JUMP_VELOCITY: float = -540.0
const GRAVITY: float = 1440.0
const PLAYER_MAX_RUN_SPEED: float = 330.0
```

If you change character physics, the navigation graph automatically adapts (uses same constants).

### Character Collision Box

Simulation uses character dimensions:

```gdscript
const CHARACTER_HALF_WIDTH := 12.0   # ±12px = 24px width
const CHARACTER_HEIGHT := 29.0       # Height for collision checks
```

These approximate the character capsule/box for collision checking during jump arc simulation.

## Using the Graph

### In AI Controllers

**Script**: `res://scripts/characters/cpu_controller.gd`

NPCs use the navigation graph for pathfinding:

```gdscript
# Find closest node to current position
var start_node := level_nav.find_closest_node(character.global_position)

# Find closest node to target
var goal_node := level_nav.find_closest_node(target_position)

# Get adjacency list
var adjacency := level_nav.get_adjacency_list()

# Pathfind from start to goal using A* or similar
var path := _find_path(start_node, goal_node, adjacency)
```

### API Reference

**Key Functions**:

```gdscript
# Get the complete graph data
func get_graph() -> Dictionary

# Find node by ID
func get_node_by_id(node_id: int) -> NodeEntry

# Get adjacency list (node_id -> array of edges)
func get_adjacency_list() -> Dictionary

# Find closest node to a world position
func find_closest_node(world_pos: Vector2, vertical_tolerance: float) -> NodeEntry

# Get all nodes in a platform
func get_nodes_for_platform(platform_id: int) -> Array

# Rebuild graph (if level changes)
func rebuild_graph() -> void
```

**Edge Structure**:
```gdscript
{
	"from": int,             # Source node ID
	"to": int,               # Target node ID
	"type": String,          # "walk", "jump", or "drop"
	"points": Array,         # Path points (Vector2 array)
	"cost": float,           # Edge cost (path length)
	"meta": Dictionary       # Type-specific data (e.g. jump time)
}
```

## Level Design Guidelines

### Design for AI Navigation

✅ **Do**:
- Use clear, contiguous platforms (2+ tiles wide)
- Space platforms 2-3 tiles apart vertically
- Keep horizontal gaps ≤ 3 tiles
- Place semisolid platforms for vertical movement
- Test with debug visualization enabled

❌ **Don't**:
- Create 1-tile-wide platforms (NPCs struggle)
- Make gaps > 4 tiles (unreachable by NPCs)
- Use only decorative tiles (NPCs can't see them)
- Create enclosed areas without drop/jump access
- Forget to test NPC navigation

### Common Issues

**NPCs can't reach certain platforms**:
- Check jump distance (too far?)
- Verify solid/semisolid tiles are painted
- Enable debug view to see if jump edges exist
- Add intermediate platforms if needed

**NPCs get stuck in corners**:
- Add semisolid platforms for escape routes
- Ensure walk edges connect within platforms
- Check that spawn points aren't in dead ends

**NPCs don't jump**:
- Verify jump edges appear in debug view
- Check that max_jump_horizontal_tiles is sufficient
- Ensure no obstacles blocking jump arcs

**Graph building is slow**:
- Reduce max_jump_horizontal_tiles (fewer jump checks)
- Reduce max_jump_up_tiles
- Optimize level size (fewer tiles = faster build)

### Testing Navigation

**Workflow**:
1. Create level layout
2. Enable "Debug Draw Graph" on level root node
3. Run scene (F6)
4. Observe navigation graph overlay
5. Check that all platforms have nodes
6. Verify jump edges connect platforms
7. Test with NPCs to see pathfinding in action

**Iterative Refinement**:
- If NPCs don't reach an area, add intermediate platforms
- If jump edges are missing, reduce gap distances
- If NPCs cluster, spread spawn points using navigation data

## Performance

### Graph Building

**When**:
- Level _ready() - Initial build at level load
- Manually triggered via rebuild_graph()

**Cost**:
- O(n) for node creation (n = tile count)
- O(n) for walk/drop edges
- O(n²) for jump edges (most expensive)

**Optimization**:
- Jump checks use early rejection (distance, angle, velocity)
- Border detection skips outer wall tiles
- Platform grouping reduces edge count

**Typical Times**:
- Small level (20×15): ~10-20ms
- Medium level (40×22): ~50-100ms
- Large level (60×30): ~200-300ms

### Runtime Pathfinding

The graph is built once at level load. Pathfinding uses the precomputed graph:

**AI pathfinding cost**: O(n log n) with A* (n = node count)

This is efficient enough for multiple NPCs (7 tested).

### Solid Border Optimization

The system detects fully-enclosed levels:

```gdscript
func _detect_solid_border() -> void
```

If the level has a complete solid perimeter, the border tiles are excluded from collision checks during jump arc simulation. This speeds up jump feasibility checks.

## Advanced Topics

### Custom Edge Types

To add new edge types (e.g., "climb", "swim"):

1. Add constant in level_navigation.gd:
   ```gdscript
   const EDGE_CLIMB := "climb"
   ```

2. Create build function:
   ```gdscript
   func _build_climb_edges() -> void
   ```

3. Call in _build_navigation_graph()

4. Update debug visualization

5. Handle in AI pathfinding logic

### Dynamic Graph Updates

Currently the graph is static (built once). For dynamic levels:

```gdscript
# Rebuild entire graph
level_navigation.rebuild_graph()

# Or implement incremental updates (advanced)
```

### Weighted Edges

Edges have a `cost` property (path length). To add custom weights:

```gdscript
# In _add_edge()
edge["cost"] = _polyline_length(points) * weight_multiplier
```

Use case: Discourage certain edge types (e.g., make jumps "expensive").

### Multi-Layer Platforms

For complex geometry with overlapping platforms, you might need custom platform detection:

```gdscript
# Current logic groups by row (y-coordinate)
# For multi-layer, you might need 2D clustering
```

## Related Topics

- **[Getting Started](getting-started.md)** - Level creation includes navigation setup
- **[Tile Layers](tile-layers.md)** - What tiles the navigation system sees
- **[Spawn Points](spawn-points.md)** - NPCs navigate between spawn points
- [level_navigation.gd](../../scripts/levels/level_navigation.gd) - Full implementation
- [cpu_controller.gd](../../scripts/characters/cpu_controller.gd) - AI pathfinding usage
- [game_constants.gd](../../scripts/core/game_constants.gd) - Physics used in simulation

---

**You've completed the Level Design documentation!** Return to the [Level Design Guide](README.md) or explore other documentation sections.

