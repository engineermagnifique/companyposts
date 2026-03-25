# Offline Posts Manager

A Flutter app to manage media posts offline using SQLite.

---

## Screenshots

| Home | Add |
| ---- | ---- |
| ![Home](https://raw.githubusercontent.com/engineermagnifique/companyposts/main/demo/Home.png) | ![Home2](https://raw.githubusercontent.com/engineermagnifique/companyposts/main/demo/New%20post.png) |

| View | Delete |
| ---- | ------ |
| ![View](https://raw.githubusercontent.com/engineermagnifique/companyposts/main/demo/Details.png) | ![Delete](https://raw.githubusercontent.com/engineermagnifique/companyposts/main/demo/Delete.png) |

| SaveChanges | Deleted |
| ----------- | ------- |
| ![Save](https://raw.githubusercontent.com/engineermagnifique/companyposts/main/demo/SaveChanges.png) | ![Deleted](https://raw.githubusercontent.com/engineermagnifique/companyposts/main/demo/deleted.png) |
---

## Project Structure

```
offline_posts_manager/
├── demo/                              ← Screenshots
│   Files for presentation
├── lib/
│   ├── main.dart                      ← App entry point
│   ├── theme/
│   │   └── app_theme.dart             ← Colors, gradients, shadows, typography
│   ├── models/
│   │   └── post.dart                  ← Post data model
│   ├── database/
│   │   └── database_helper.dart       ← SQLite singleton — full CRUD + search
│   ├── screens/
│   │   ├── home_screen.dart           ← Dashboard: stats, filters, search, post list
│   │   ├── post_detail_screen.dart    ← Full post view with metadata & actions
│   │   └── post_form_screen.dart      ← Add / Edit form with category & status picker
│   └── widgets/
│       └── widgets.dart               ← AuthorAvatar, PostCard, StatusBadge, FilterTab, StatCard
└── pubspec.yaml
```

---

## Built With

- [Flutter](https://flutter.dev) — UI framework
- [sqflite](https://pub.dev/packages/sqflite) — Local SQLite database
- [path](https://pub.dev/packages/path) — Database file path resolution
- [google_fonts](https://pub.dev/packages/google_fonts) — Nunito typeface

---

## Features

- **Full CRUD** — Create, Read, Update, Delete posts stored locally
- **Offline-first** — All data lives on-device via SQLite, no internet required
- **Filter tabs** — Browse All / Published / Draft / Archived posts
- **Live search** — Search by title, content, or author name
- **Status workflow** — Track posts from Draft → Published → Archived
- **Category tags** — News, Tech, Sports, Health, Culture, Business, Other
- **Author avatars** — Gradient initials with 7 selectable colors
- **Stats header** — Real-time post counts in the dashboard header
- **Sample data** — 5 pre-loaded posts on first launch

---

## Setup & Run

### Prerequisites

- Flutter SDK ≥ 3.10
- Android Studio / VS Code with Flutter plugin
- Android or iOS device / emulator

### Steps

```bash
# 1. Copy the lib/ folder into your Flutter project root

# 2. Use the provided pubspec.yaml or add dependencies manually
flutter pub add sqflite path google_fonts

# 3. Get packages
flutter pub get

# 4. Run the app
flutter run
```

---

## Database Schema

```sql
CREATE TABLE posts (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  title            TEXT NOT NULL,
  content          TEXT NOT NULL,
  category         TEXT NOT NULL,
  status           TEXT NOT NULL,        -- draft | published | archived
  authorName       TEXT NOT NULL,
  authorInitials   TEXT NOT NULL,
  authorColorIndex INTEGER NOT NULL DEFAULT 0,
  createdAt        TEXT NOT NULL,        -- ISO 8601
  updatedAt        TEXT NOT NULL         -- ISO 8601
)
```

---

## Key CRUD Methods

```dart
// Create
DatabaseHelper.instance.insertPost(post);

// Read all
DatabaseHelper.instance.getAllPosts();

// Read one
DatabaseHelper.instance.getPost(id);

// Filter by status
DatabaseHelper.instance.getPostsByStatus('published');

// Search
DatabaseHelper.instance.searchPosts('keyword');

// Update
DatabaseHelper.instance.updatePost(post);

// Delete
DatabaseHelper.instance.deletePost(id);

// Stats
DatabaseHelper.instance.getPostCounts();
```