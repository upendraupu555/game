# Sound Assets

This directory contains all sound effect files for the 2048 game.

## Required Sound Files

### UI Navigation Sounds
- `ui_button_tap.mp3` - Button tap/press sound
- `ui_navigation.mp3` - Screen transition sound
- `ui_menu_open.mp3` - Menu opening sound
- `ui_menu_close.mp3` - Menu closing sound
- `ui_back.mp3` - Back button sound

### Game Sounds
- `game_tile_move.mp3` - Tile sliding/movement sound
- `game_tile_merge.mp3` - Tile merging sound
- `game_tile_appear.mp3` - New tile appearance sound
- `game_blocker_create.mp3` - Blocker tile creation sound
- `game_blocker_merge.mp3` - Blocker tile merge/disappear sound

### Powerup Sounds
- `powerup_unlock.mp3` - Powerup milestone achievement sound
- `powerup_tile_freeze.mp3` - Tile Freeze activation sound
- `powerup_tile_destroyer.mp3` - Tile Destroyer activation sound
- `powerup_row_clear.mp3` - Row Clear activation sound
- `powerup_column_clear.mp3` - Column Clear activation sound

### Time Attack Sounds
- `timer_tick.mp3` - Timer countdown ticking (subtle)
- `timer_warning.mp3` - Timer warning sound (last 10-30 seconds)
- `timer_time_up.mp3` - Time up/game over sound

### Game State Sounds
- `game_over.mp3` - Game over sound
- `game_win.mp3` - Game win sound
- `game_new.mp3` - New game start sound
- `game_pause.mp3` - Game pause sound
- `game_resume.mp3` - Game resume sound

## Sound Requirements

- **Format**: MP3 files for broad compatibility
- **Duration**: Keep sounds brief (0.1-2 seconds for most effects)
- **Volume**: Normalized to prevent clipping
- **Quality**: 44.1kHz, 16-bit minimum
- **Style**: Pleasant, non-intrusive, game-appropriate

## Implementation Notes

- All sounds are preloaded for performance
- Volume is controlled by category (UI, Game, Powerup, Timer)
- Sounds respect system mute and volume settings
- Maximum 5 concurrent sounds to prevent audio chaos
- Sounds are cached for 10 minutes to optimize memory usage

## Adding New Sounds

1. Add the sound file to this directory
2. Update `SoundAssets` class in `app_constants.dart`
3. Add the sound type to `SoundEventType` enum
4. Map the sound in `SoundService._initializeSoundPaths()`
5. Update the `allSounds` list for preloading
