# AI Storyteller Feature Integration

The goal is to implement an "AI Storyteller" (AI Ertakchi) feature where the app tells personalized stories to the child, incorporating their name or chosen characters. This will be an interactive "Game Console" experience.

## User Review Required

> [!IMPORTANT]
> **AI Content**: For this demo version, I will implement a set of **Dynamic Story Templates**. These templates will allow the app to inject the child's name into various adventures (e.g., "Abdurahmon and the Magic Dragon"). In a future phase, this can be connected to a live GPT API for infinite unique stories.
>
> **Narration**: The feature will leverage the existing `VoiceService` (TTS) to read the stories aloud in the configured Uzbek/Turkish/English voice.

## Proposed Changes

### [Core Providers]

#### [MODIFY] [kids_providers.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/core/services/kids_providers.dart)
- Add "AI Storyteller" to the `gameCategoriesProvider`.

### [Mini-Game Features]

#### [MODIFY] [mini_games_screen.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/features/mini_games/mini_games_screen.dart)
- Implement `_buildStorytellerGame()`:
    - **Story Selector**: Cards for different themes (Space, Jungle, Magic Castle).
    - **Personalization Input**: Field to enter/confirm the Hero's name.
    - **Story Console**: A text area with "Play/Pause/Stop" buttons for the AI voice.
    - **Visuals**: Changing background emojis/images based on the story theme.

### [Voice Service]

#### [MODIFY] [voice_service.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/core/services/voice_service.dart)
- Add `stop()` method to halt narration if the user leaves the screen.

## Verification Plan

### Manual Verification
1.  Navigate to the "AI Storyteller" tab in the Mini Games Arcade.
2.  Choose a story theme (e.g., "The Magic Forest").
3.  Verify that your name is correctly mentioned in the story text.
4.  Press "Play" and verify that the AI voice reads the personalized story aloud.
5.  Press "Stop" and verify the voice stops immediately.
