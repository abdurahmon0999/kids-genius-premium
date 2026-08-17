# Implementation Plan - User Management in Admin Dashboard

Implement the functional User Management section in the Admin Dashboard to allow admins to view and manage registered users.

## Proposed Changes

### Features: Admin Dashboard
#### [MODIFY] [admin_dashboard_screen.dart](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/lib/features/admin_dashboard/admin_dashboard_screen.dart)
- Implement `_showManageUsersDialog(BuildContext context)` to fetch and display users from the `users` collection.
- Show user details: Name, Role, Level, Coins, and XP.
- Add functionality to delete a user with a confirmation dialog.
- Update the `user_management` action tile to call this new function.

### Core: Translations
#### [MODIFY] [uz.json](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/assets/translations/uz.json), [ru.json](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/assets/translations/ru.json), [en.json](file:///C:/Users/Пользователь/OneDrive/Desktop/untitled/assets/translations/en.json)
- Add keys like `delete_user_confirm`, `user_deleted_success`, `total_users`.

## Verification Plan

### Manual Verification
1.  **Open Admin Panel**: Navigate to Profile -> Admin 👑 (Key: 7777).
2.  **User Management**: Click "Foydalanuvchilarni boshqarish" (User Management).
3.  **List Check**: Verify that a list of users appears with their correct stats.
4.  **Delete User**: Attempt to delete a test user and verify the deletion in Firestore.
