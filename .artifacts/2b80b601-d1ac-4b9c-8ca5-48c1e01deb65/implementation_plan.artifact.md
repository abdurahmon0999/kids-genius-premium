# Implementation Plan - Sky Rush Game Integration

Integrate a high-quality, futuristic endless runner game called **Sky Rush** into the Kids Genius platform.

## Proposed Changes

### Core: Models & Infrastructure
#### [MODIFY] [kids_models.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/core/models/kids_models.dart)
- Add `SkyRushStats`, `SkyRushCharacter`, and `SkyRushItem` models.
- Track distances, coins, crystals, and unlocked characters/skins.

#### [MODIFY] [kids_providers.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/core/services/kids_providers.dart)
- Add "Sky Rush" to `gameCategoriesProvider`.
- Create `skyRushProvider` to manage game state, inventory, and session rewards.

#### [MODIFY] [storage_service.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/core/services/storage_service.dart)
- Implement `saveSkyRushStatsLocal` and `loadSkyRushStatsLocal` to persist progress.

### Features: Sky Rush Game
#### [NEW] Directory: `lib/features/sky_rush/`
- **`sky_rush_home_screen.dart`**: Futuristic menu with animated hero, character selection, and inventory access.
- **`sky_rush_game_screen.dart`**: The core game engine.
    - 3D-like perspective using 2D `CustomPainter`.
    - Lane-based movement (Left, Center, Right).
    - Power-ups: Magnet, Shield, Jet Boost, Freeze, Double Coin.
    - Procedural obstacle and coin spawning.
- **`widgets/`**: Virtual controls (swipe detection), HUD, and glassmorphism-style dialogs (Game Over, Level Up, Mystery Box).

### Core: Translations
#### [MODIFY] [uz.json](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/assets/translations/uz.json), [ru.json](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/assets/translations/ru.json), [en.json](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/assets/translations/en.json)
- Add keys for worlds (Sky Valley, Neon City), characters, power-ups, and game-specific UI.

## Verification Plan

### Manual Verification
1.  **Entry**: Launch Sky Rush from the Mini Games menu.
2.  **Home Screen**: Verify character animation and button functionality (Inventory, Characters).
3.  **Gameplay**:
    - Test swiping (Left/Right/Up/Down).
    - Verify power-up effects (e.g., Magnet pulling coins).
    - Test obstacle collisions (losing a life).
4.  **Progression**: Verify coin collection, distance scoring, and high-score saving.
5.  **Shop/Inventory**: Purchase a skin or character and verify it updates in the game.
6.  **Performance**: Ensure 60 FPS on both Web and Mobile.
