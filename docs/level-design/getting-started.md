# Getting Started: Creating Your First Level

This tutorial walks you through creating a complete level for Super Tux War from scratch.

## Prerequisites

- Godot 4.5.1 or later
- Super Tux War project opened in Godot Editor
- Basic familiarity with Godot's scene editor

## Step 1: Create the Level Scene

### Option A: Duplicate an Existing Level (Recommended)

1. In the FileSystem panel, navigate to `res://scenes/levels/`
2. Right-click `level01.tscn` → **Duplicate**
3. Rename to `level03.tscn` (or next available number)
4. Double-click to open the scene

### Option B: Create from Scratch

1. **Create Root Node**
   - Scene → New Scene
   - Add Node2D as root
   - Rename to "TileMapLevel"
   - Attach script: `res://scripts/levels/level_navigation.gd`

2. **Add Tile Layers** (as children of TileMapLevel)
   
   Add three TileMapLayer nodes in this order:
   
   - **DecorationTileMap**
     - Z-Index: -10
     - TileSet: `res://assets/tilesets/smw_blocks.tres`
   
   - **GroundTileMap**
     - Z-Index: 0
     - TileSet: `res://assets/tilesets/smw_blocks.tres`
   
   - **SemisolidTileMap**
     - Z-Index: 0
     - TileSet: `res://assets/tilesets/smw_blocks.tres`

3. **Add HUD Layer**
   - Add CanvasLayer node
   - Rename to "HUD"

4. **Add Spawn Manager**
   - Add Node as child of TileMapLevel
   - Rename to "SpawnManager"
   - Attach script: `res://scripts/levels/spawn_manager.gd`

5. **Add Level Info**
   - Add Node as child of TileMapLevel
   - Rename to "LevelInfo"
   - Attach script: `res://scripts/levels/level_info.gd`
   - In Inspector, set **Level Name** (e.g., "Test Arena")

6. **Save Scene**
   - Save as `res://scenes/levels/level03.tscn`

Your scene tree should look like this:

```
TileMapLevel (Node2D) [level_navigation.gd]
├── DecorationTileMap (TileMapLayer) [z-index: -10]
├── GroundTileMap (TileMapLayer) [z-index: 0]
├── SemisolidTileMap (TileMapLayer) [z-index: 0]
├── HUD (CanvasLayer)
├── SpawnManager (Node) [spawn_manager.gd]
└── LevelInfo (Node) [level_info.gd]
```

## Step 2: Design Your Level Layout

### Planning

Before painting tiles, sketch your level design:

- **Arena Size**: Target ~40×22 tiles (1280×704 pixels)
- **Platform Layout**: Multiple height levels for vertical gameplay
- **Open Spaces**: Room for 4-8 characters to move and fight
- **Spawn Locations**: Where you'll place spawn points (at least 4-6)

### Design Tips

- Start with a floor perimeter
- Add 2-3 platform levels at different heights
- Leave 2+ tiles of headroom above platforms
- Create jump gaps of 2-3 tiles
- Think about combat flow and movement

## Step 3: Paint Tiles

### Setting Up the TileMap Editor

1. Select **GroundTileMap** in the scene tree
2. Switch to the TileMap editor (bottom panel)
3. Select the solid block tile from the palette

### Paint Solid Ground

1. Select the **GroundTileMap** layer
2. Choose the solid tile (01.png from `assets/blocks/solid/`)
3. Use the pencil tool to paint:
   - Floor perimeter (bottom of level)
   - Side walls (left and right boundaries)
   - Top wall or ceiling (optional)
   - Solid platforms

**Example Layout**:

```
████████████████████████████████████████
█                                      █
█           ████████                   █
█                           ████████   █
█   ████████                           █
█                   ████████           █
█                                      █
████████████████████████████████████████
```

### Add Semisolid Platforms

1. Select **SemisolidTileMap** in the scene tree
2. Choose the semisolid tile (01.png from `assets/blocks/semisolid/`)
3. Paint one-way platforms between solid platforms
   - Use single rows (platforms are only 1 tile thick)
   - Vary heights for interesting vertical gameplay

**Semisolid Behavior**:
- Characters can jump up through them
- Characters stand on top
- Characters can drop through with Down+Jump

### Add Decorations (No tilemaps for this yet)

1. Select **DecorationTileMap**
2. Add visual details (these have no collision)
3. Keep it subtle - gameplay clarity is important

## Step 4: Add Spawn Points

Spawn points determine where players and NPCs appear.

### Add Spawn Point Scenes

1. Ensure **SpawnManager** is selected in the scene tree
2. In the top menu: Scene → Instantiate Child Scene
3. Select `res://scenes/objects/spawn_point.tscn`
4. Click "Open"
5. Move the spawn point to a good location (on a platform)
6. Repeat 8-16 times for multiple spawn points

### Positioning Spawn Points

**Good Placement**:
- Spread throughout the level
- On solid ground or semisolid platforms
- Away from death hazards
- At least 4 tiles (128px) apart

**Bad Placement**:
- All clustered together
- Too close to level edges
- Directly above/below each other
- In hard-to-reach corners

### Configure Spawn Points (Optional)

Select a spawn point and check the Inspector:

- **Allowed**: ANY (player or NPC), PLAYER (player only), NPC (NPC only)
- **Radius**: 16.0 (visual indicator)
- **Weight**: 1 (unused currently)

Most spawn points should use **ANY** (default).

## Step 5: Configure Level Metadata

1. Select **LevelInfo** node
2. In the Inspector, set:
   - **Level Name**: A friendly name (e.g., "Sky Fortress", "Dungeon Arena")

This name appears in the level select UI.

## Step 6: Test Your Level

### Quick Test

1. Click the "Run Current Scene" button (▶ icon with scene)
2. Your level should load with 1 player (Tux) and 1 NPC (Beasty) by default
3. Test movement, jumping, and platform behavior

**Controls**:
- Move: A/D or Arrow Keys
- Jump: Space or W
- Drop Through Platform: S + Space

### Test with Multiple NPCs

To test with more characters:

1. Run the main game (F5 or click the main play button)
2. From the start menu:
   - Click "Options"
   - Set CPU Count to 7
   - Go back and click "Start"
3. Test spawn distribution and combat flow

### Testing Checklist

- [ ] Can spawn at all spawn points
- [ ] Can reach all platforms
- [ ] Semisolid platforms work correctly
- [ ] No characters stuck or unreachable areas
- [ ] Spawn points spread out well
- [ ] Level feels fun with 4+ characters

### Common Issues

**Characters spawn in walls/floor**:
- Move spawn points higher (above the ground)

**Can't reach a platform**:
- Reduce gap distance or add intermediate platforms

**Spawns too close together**:
- Spread spawn points at least 4 tiles apart

**NPCs don't move**:
- Ensure GroundTileMap and SemisolidTileMap have tiles painted
- Check that level_navigation.gd is attached to root node

## Step 7: Generate Level Thumbnail

The baker plugin automatically creates thumbnails for the level select screen.

### Automatic Generation (Preferred)

The plugin automatically bakes thumbnails when you save level scenes. Just save your level and the thumbnail will be generated.

### Manual Generation

1. In the top menu, click **Project → Tools → Level Thumbs: Bake**
2. Wait for baking to complete (check console output)
3. Check `assets/level_thumbs/` for `level03.png`

See [Level Thumbnails](level-thumbnails.md) for more details.

## Step 8: Add Level to the Game

### Update Start Menu (if needed)

The level should automatically appear in the level select if:
1. It's saved in `scenes/levels/`
2. Filename starts with "level" (e.g., `level03.tscn`)
3. Thumbnail was generated

You may need to update `ui_manager.gd` or the start menu to include the new level in the selection UI.

## Next Steps

### Improve Your Level

- Add more varied platform layouts
- Experiment with different tile types (ice, death tiles)
- Place interactive objects (gravestones spawn naturally on death)
- Add decorative elements for visual polish

### Learn More

- **[Tile Layers & Block Types](tile-layers.md)** - Deep dive into the tile system
- **[Spawn Points](spawn-points.md)** - Advanced spawn configuration
- **[Navigation Graph](navigation-graph.md)** - How AI navigates your level

### Study Existing Levels

Open and analyze the existing levels:
- `scenes/levels/level01.tscn` - Basic arena
- `scenes/levels/level02.tscn` - Multi-tier platforms

Look at their tile placement, spawn distribution, and design patterns.

## Tips for Great Levels

1. **Start Simple** - Get the basic layout working first
2. **Test Early** - Play your level frequently during design
3. **Think Vertically** - Use multiple platform heights
4. **Enable Combat** - Open spaces where players can stomp each other
5. **Avoid Camping** - No overpowered defensive positions
6. **Balance Risk/Reward** - High platforms should have trade-offs

## Troubleshooting

### Level doesn't load

- Check that the scene is saved properly
- Ensure all required nodes are present
- Check console for error messages

### Tiles don't appear

- Verify TileSet is assigned to all TileMapLayer nodes
- Check z-index values (DecorationTileMap should be -10)

### NPCs don't navigate properly

- Ensure level_navigation.gd is attached to root node
- Check that tiles are on GroundTileMap and SemisolidTileMap layers
- Open the level in debug mode to see navigation graph and jump arcs

### Thumbnail not generating

- Ensure level filename starts with "level"
- Check that level is saved in `scenes/levels/`
- Manually run the baker: Project → Tools → Level Thumbs: Bake

---

**Congratulations!** You've created your first Super Tux War level. Keep experimenting and iterating to create fun, competitive arenas.

**Next**: [Tile Layers & Block Types →](tile-layers.md)

