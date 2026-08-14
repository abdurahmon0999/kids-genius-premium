# Magic Quests & Sensory Feedback System 🎯📳

The goal is to implement a daily quest system to increase user retention and add haptic/visual feedback to make the app feel more "premium" and interactive.

## User Review Required

> [!IMPORTANT]
> **Haptic Feedback**: This will use the device's vibration motor. On some browsers (Web), vibration support might be limited or require a user gesture first.
>
> **Quest Reset**: Quests will be "Daily". For this implementation, I will simulate the daily reset logic. In a full production app, this would be handled by a server-side cron job.

## Proposed Changes

### [Models]

#### [MODIFY] [kids_models.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/core/models/kids_models.dart)
- Add `QuestModel` class with fields: `id`, `title`, `goal`, `currentProgress`, `rewardCoins`, `iconEmoji`, `isCompleted`.

### [Providers]

#### [MODIFY] [kids_providers.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/core/services/kids_providers.dart)
- Add `QuestNotifier` to manage the daily quest list.
- Implement `updateQuestProgress(String categoryKey)` to automatically increment relevant quests.
- Add `claimQuestReward(String questId)` to give coins/XP to the user.

### [Mini-Games & Feedback]

#### [MODIFY] [mini_games_screen.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/features/mini_games/mini_games_screen.dart)
- Integrate `HapticFeedback.lightImpact()` on correct answers.
- Integrate `HapticFeedback.heavyImpact()` on incorrect answers.
- Call `questProvider.updateQuestProgress()` when a question is answered correctly.
- Add a "Glow" visual effect around the question when correct.

### [User Interface]

#### [MODIFY] [child_dashboard_screen.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/features/child_dashboard/child_dashboard_screen.dart)
- Add a "Daily Quests 🎯" horizontal list or grid.
- Show progress bars for each quest (e.g., "Math Master: 2/3").
- Add a "Claim" button that triggers a confetti explosion.

---

## Verification Plan

### Manual Verification
1. **Quest Tracking**: Note a quest (e.g., "Answer 3 Math Questions"). Play the Math game and verify the progress increases on the dashboard.
2. **Haptic Feedback**: Play any game on a physical device and verify it vibrates/pulses on answers.
3. **Reward Claiming**: Complete a quest, click "Claim", and verify your coin balance increases.
