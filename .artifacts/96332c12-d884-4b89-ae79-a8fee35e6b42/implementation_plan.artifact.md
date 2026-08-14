# Review Section Implementation Plan

Implementing a dedicated review section in the `InfoScreen` with local storage persistence and local notifications.

## User Review Required

> [!IMPORTANT]
> The review section will be added to the bottom of the **Info Screen**.
> Reviews will be saved to both **Firestore** (for global visibility) and **LocalStorage** (as requested).
> A **Local Notification** will be triggered immediately after a successful submission.

## Proposed Changes

### Core / Services

#### [MODIFY] [kids_providers.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/core/services/kids_providers.dart)
- Add `localReviewsProvider` using `StateNotifier` to manage reviews stored in `localStorage` reactively.
- This will allow the UI to update immediately when a new review is added locally.

### Features

#### [MODIFY] [info_screen.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/features/info/info_screen.dart)
- Convert `InfoScreen` to a `ConsumerStatefulWidget`.
- Add a review input field (TextFormField) and a "Submit" button.
- Display a list of reviews at the bottom of the screen.
- Implement the submission logic:
    - Save to `localStorage` via `StorageService`.
    - Save to `Firestore` via `FirebaseFirestore`.
    - Trigger a local notification via `NotificationService`.
    - Update the local provider state.

### Translations

#### [MODIFY] [uz.json](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/assets/translations/uz.json)
#### [MODIFY] [en.json](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/assets/translations/en.json)
#### [MODIFY] [ru.json](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/assets/translations/ru.json)
- Add keys for "write_review", "review_accepted", "reviews_list", etc.

## Verification Plan

### Manual Verification
1.  Navigate to the **Info Screen**.
2.  Scroll down to the "Write a Review" section.
3.  Type a comment and press "Submit".
4.  Verify that a **Local Notification** appears with the text: "Siz yozgan sharh qabul qilindi".
5.  Verify that the new review appears at the bottom of the list.
6.  Restart the app and verify that the review is still there (loaded from `localStorage`).
