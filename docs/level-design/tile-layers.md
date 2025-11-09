# Tile Layers & Block Types

Understanding the tile system is essential for creating engaging Super Tux War levels. This guide covers all tile layers, block types, and their behaviors.

## Overview

Super Tux War uses a **32×32 pixel tile grid** with multiple TileMapLayer nodes for different purposes. The tile system follows Super Mario War conventions for clear, responsive collision.

## Tile Layers

Layers are rendered **back to front** based on z-index:

| Layer | Z-Index | Purpose | Collision |
|-------|---------|---------|-----------|
| DecorationTileMap | -10 | Background visuals | None |
| GroundTileMap | 0 | Solid collision | Full |
| SemisolidTileMap | 0 | One-way platforms | Top only |
| Players/NPCs | 10 | Characters | Character bodies |

### Layer Details

#### DecorationTileMap
**Purpose**: Visual elements without collision

- Renders behind everything else (z-index: -10)
- Use for background details, patterns, atmosphere
- Does not affect gameplay or navigation
- Keep decorations subtle to maintain gameplay clarity

**Best Practices**:
- Use sparingly to avoid visual clutter
- Don't obscure gameplay elements
- Use consistent style with solid tiles

#### GroundTileMap
**Purpose**: Solid collision geometry

- Primary collision layer (z-index: 0)
- Full collision on all sides
- Contains walls, floors, ceilings, and solid blocks
- Used by AI navigation system

**Block Types**:
- Solid (default)
- Ice (reduced friction)
- Death tiles (planned)

#### SemisolidTileMap
**Purpose**: One-way platforms

- Same z-index as ground (0) but separate collision
- Characters can jump up through from below
- Characters stand on top surface
- Characters can drop through with Down+Jump
- Used by AI navigation system

**Design Notes**:
- Usually 1 tile thick (single row)
- Great for vertical level design
- Essential for multi-tier arenas

## Block Types

### Solid Blocks

**Location**: `assets/blocks/solid/`  
**Layer**: GroundTileMap  
**Collision**: Full (all sides)

**Behavior**:
- Characters collide from all directions
- Cannot be jumped through or dropped through
- Used for floors, walls, and ceilings

**Physics Properties**:
- Default friction: `FRICTION_GROUND` (12.0 px/s²)
- Default acceleration: `PLAYER_ACCEL` (30.0 px/s²)

**Usage**:
```
████████  ← Solid ceiling
█      █  ← Solid walls
█      █
████████  ← Solid floor
```

**Use Cases**:
- Level boundaries (perimeter walls)
- Main platforms
- Walls and obstacles
- Enclosed spaces

### Ice Blocks

**Location**: `assets/blocks/ice/`  
**Layer**: GroundTileMap  
**Collision**: Full (all sides)

**Behavior**:
- Solid collision like normal blocks
- **Reduced friction** when standing on top
- Reduced acceleration for slippery movement

**Physics Properties**:
- Ice friction: `FRICTION_ICE` (3.6 px/s²) - 30% of normal
- Ice acceleration: `PLAYER_ACCEL_ICE` (7.5 px/s²) - 25% of normal

**Movement Feel**:
- Characters slide when stopping
- Harder to change direction
- Maintains momentum longer
- Creates fun/challenging movement

**Usage**:
```
◈◈◈◈◈◈◈◈  ← Ice platform
```

**Use Cases**:
- Slippery platforms
- Challenge areas
- Speed boost sections
- Hazard zones (combined with edges/gaps)

### Semisolid Platforms

**Location**: `assets/blocks/semisolid/`  
**Layer**: SemisolidTileMap  
**Collision**: Top surface only

**Behavior**:
- **Jump up through** from below (no collision)
- **Stand on top** surface
- **Drop through** with Down+Jump input
- AI characters can use them for pathfinding

**Movement Rules**:
- Approaching from below: No collision (pass through)
- On top surface: Full collision (stand normally)
- Down+Jump input: Temporarily disable collision (drop through)

**Usage**:
```
       ▬▬▬▬▬▬  ← Semisolid platform (1 tile thick)
     
   
  ▬▬▬▬▬▬      ← Another semisolid platform

```

**Use Cases**:
- Multi-tier level design
- Vertical movement between floors
- Escape routes (drop down)
- Combat variety (attack from above/below)

**Design Tips**:
- Use 1-tile-thick rows
- Space at least 3 tiles apart vertically
- Combine with solid platforms for variety
- Place strategically for combat flow

### Death Blocks (Planned)

**Location**: `assets/blocks/death/`  
**Layer**: GroundTileMap  
**Status**: Partially implemented

#### Death Floor (Spikes/Lava)

**Visual**: `death/floor/01.png`  
**Collision**: Top surface kills characters  
**Behavior** (planned):
- Kill character on contact from above
- Instant respawn trigger
- Can be combined with solid sides

**Usage**:
```
████████
██☠☠☠☠██  ← Death floor (center)
████████
```

#### Death Ceiling (Stalactites)

**Visual**: `death/ceiling/01.png`  
**Collision**: Bottom surface kills characters  
**Behavior** (planned):
- Kill character on contact from below
- Instant respawn trigger

**Usage**:
```
████████
██☠☠☠☠██  ← Death ceiling (center)
████████
```

**Design Guidelines** (when implemented):
- Use sparingly - death tiles are punishing
- Clearly visible and distinct from normal tiles
- Place in intentional hazard zones, not random
- Provide safe paths around death areas

## TileSet Configuration

The game uses a central TileSet: `res://assets/tilesets/smw_blocks.tres`

### TileSet Structure

Each tile type has:
- **Texture**: PNG image (32×32 pixels)
- **Physics Layer**: Collision shape and layer mask
- **Custom Data**: Flags for special behaviors

### Physics Layers

| Layer | Name | Purpose |
|-------|------|---------|
| 0 | Solid | Full collision (GroundTileMap) |
| 1 | Semisolid | Top-only collision (SemisolidTileMap) |

### Custom Data Flags (Planned)

Tiles can have custom metadata:

```gdscript
# Example custom data (not fully implemented yet)
tile_data.set_custom_data("ice", true)
tile_data.set_custom_data("death_top", true)
tile_data.set_custom_data("death_bottom", true)
```

### Collision Shapes

**Solid Blocks**:
- Full 32×32 rectangle
- Collides on all sides

**Semisolid Blocks**:
- Thin rectangle at top edge (~4px tall, 32px wide)
- One-way collision enabled
- Characters pass through from sides and bottom

**Ice Blocks**:
- Full 32×32 rectangle (same as solid)
- Ice flag triggers physics changes in character controller

## Working with Tiles

### Painting Tiles

1. Select the appropriate TileMapLayer in the scene tree
2. Open the TileMap editor (bottom panel)
3. Select tile from palette
4. Use tools to paint:
   - **Pencil**: Draw individual tiles
   - **Line**: Draw straight lines
   - **Rectangle**: Fill rectangular areas
   - **Fill**: Flood fill enclosed areas

### Layer Order Matters

Always paint on the correct layer:

- **Solid geometry** → GroundTileMap
- **One-way platforms** → SemisolidTileMap
- **Visual details** → DecorationTileMap

Painting on the wrong layer will cause collision issues!

### Tile Placement Best Practices

**Floor Construction**:
```
████████████  ← Use solid blocks
```

**Platform with Semisolid Access**:
```
  ▬▬▬▬▬▬      ← Semisolid above
    
████████████  ← Solid base
```

**Multi-Level Design**:
```
  ▬▬▬▬▬▬      ← Top: Semisolid
    
   ████       ← Middle: Solid
    
  ▬▬▬▬▬▬      ← Lower: Semisolid
```

### Tile Alignment

- Use the grid snap (enabled by default)
- All tiles must align to 32×32 grid
- Misaligned tiles will cause visual/collision glitches

## Design Patterns

### Basic Arena

```
████████████████████████████████
█                              █
█   ▬▬▬▬▬      ▬▬▬▬▬           █
█                              █
█         ████████             █
█                              █
████████████████████████████████
```

- Solid perimeter
- Mixed solid and semisolid platforms
- Open spaces for combat

### Vertical Tower

```
█          ▬▬▬▬▬          █
█                         █
█    ▬▬▬▬▬      ▬▬▬▬▬     █
█                         █
█         ████████        █
█                         █
████████████████████████████
```

- Emphasis on semisolid platforms
- Vertical movement between tiers
- Drop-down shortcuts

### Ice Hazard

```
████████████████████████████████
█                              █
█         ◈◈◈◈◈◈◈◈             █  ← Ice platform
█                              █
█   ████          ████         █
█                              █
████████████████████████████████
```

- Ice platforms add challenge
- Combine with gaps for difficulty

## Navigation System Impact

The AI navigation system analyzes your tile layout to build a pathfinding graph. Understanding this helps you design levels that NPCs can navigate effectively.

### What the AI Sees

**Navigation Nodes**:
- Created on top of **GroundTileMap** solid tiles (where there's no tile above)
- Created on **SemisolidTileMap** tiles

**Navigation Edges**:
- **Walk**: Adjacent nodes on same platform
- **Jump**: Jump arcs between platforms
- **Drop**: Semisolid edges to platforms below

### Design for AI

To ensure NPCs navigate your level properly:

✅ **Do**:
- Create clear platforms with solid/semisolid tiles
- Keep jump gaps ≤3 tiles horizontal
- Space platforms 2-3 tiles apart vertically
- Use contiguous platforms (no 1-tile-wide pillars)

❌ **Don't**:
- Create ultra-narrow platforms (1-2 tiles wide)
- Make huge gaps (>4 tiles)
- Use only decoration tiles (AI won't see them)
- Create unreachable areas

For more details, see [Navigation Graph](navigation-graph.md).

## Debugging Tiles

### View Collision Shapes

In the editor:
1. Debug → Visible Collision Shapes
2. Collision shapes show as colored outlines

### Test Tile Behavior

Run the level and test:
- Jump through semisolid platforms from below
- Stand on top of semisolid platforms
- Drop through semisolid platforms with Down+Jump
- Slide on ice blocks
- Collide with solid blocks from all angles

### Common Issues

**Semisolid platform acts like solid**:
- Check that tile is on SemisolidTileMap layer, not GroundTileMap
- Verify collision shape is one-way enabled

**Can't stand on platform**:
- Ensure tile has collision shape
- Check that tile is on correct layer (not DecorationTileMap)

**AI can't navigate**:
- Confirm tiles are on GroundTileMap or SemisolidTileMap
- Check navigation graph debug view (see Navigation Graph docs)

## Asset Guidelines

### Creating New Tiles

If you want to add new tile graphics:

**Requirements**:
- Exactly 32×32 pixels
- PNG format with transparency
- Pixel art style (no filtering)
- Clear visual distinction between types

**Location**:
- `assets/blocks/solid/` - Solid blocks
- `assets/blocks/ice/` - Ice blocks
- `assets/blocks/semisolid/` - Semisolid platforms
- `assets/blocks/death/floor/` - Death floor tiles
- `assets/blocks/death/ceiling/` - Death ceiling tiles

**TileSet Integration**:
1. Import PNG into Godot (automatic)
2. Open `assets/tilesets/smw_blocks.tres`
3. Add new tile to atlas
4. Configure collision shape
5. Set physics layer (0 for solid, 1 for semisolid)
6. Add custom data if needed (ice flag, death flag)

## Related Topics

- **[Getting Started](getting-started.md)** - Level creation tutorial
- **[Spawn Points](spawn-points.md)** - Character spawning system
- **[Navigation Graph](navigation-graph.md)** - AI pathfinding
- [game_constants.gd](../../scripts/core/game_constants.gd) - Physics values
- [character_physics.gd](../../scripts/characters/components/character_physics.gd) - Movement implementation

---

**Next**: [Spawn Points →](spawn-points.md)

