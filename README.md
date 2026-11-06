# ⚡ DayForge

A modern, cloud-synced daily journaling and task management mobile application built with **Flutter**, **Supabase**, and **Riverpod**.

DayForge allows users to quickly capture daily thoughts, manage tasks, set reminder notifications, and synchronize everything across devices seamlessly.

---

## 🌟 Key Features

- **🔐 Secure Authentication**
  - Email & Password registration and login via **Supabase Auth**.
  - Reactive route guards and redirect handling using **GoRouter** and auth state change streams.
  - Safe session persistence across app launches.

- **📝 Daily Journal & Task Tracking**
  - Quick-entry input on dashboard for rapid note/task capture.
  - Rich entry details: custom titles, expandable multiline content, and custom log dates.
  - Swipe-to-dismiss gesture for quick deletion.

- **🔔 Smart Local Reminders**
  - Set custom date & time reminders for any note or task.
  - Local push notifications powered by `flutter_local_notifications` and `timezone`.
  - In-app reminder status indicators (active, past due, or cleared).

- **⚡ Reactive Architecture**
  - Declarative state management using **Riverpod 3.x** (`NotifierProvider`, `AsyncValue`).
  - Strict repository pattern separating business logic from UI.

- **🤖 Automated UI & E2E Testing**
  - Production-ready test flows using [**Maestro**](https://maestro.mobile.dev).
  - Verifies auth navigation, task CRUD operations, swipe gestures, and end-to-end flows.

---

## 🏗️ Architecture & Project Structure

```
dayforge/
├── .maestro/                     # Maestro dev automated test flows
│   ├── auth_navigation_flow.yaml # Auth & validation flow
│   ├── login_flow.yaml           # Login execution flow
│   ├── task_management_flow.yaml # Task CRUD & detail flow
│   ├── delete_task_flow.yaml     # Swipe-to-delete flow
│   ├── e2e_flow.yaml             # Complete end-to-end scenario
│   ├── subflows/                 # Reusable flow snippets (login/logout)
│   └── README.md
├── android/                      # Android project (minSdk 21, Java 17 desugaring)
├── ios/                          # iOS project
├── lib/
│   ├── config/
│   │   └── supabase_config.dart  # Supabase project URL & Anon Key
│   ├── core/
│   │   ├── router/
│   │   │   └── app_router.dart   # GoRouter configuration & route guards
│   │   └── services/
│   │       └── notification_service.dart # Local notification scheduler
│   ├── features/
│   │   ├── auth/
│   │   │   ├── providers/        # Auth state & service providers
│   │   │   └── ui/               # LoginPage & RegisterPage
│   │   └── dashboard/
│   │       ├── models/           # Task model (JSON serialization)
│   │       ├── providers/        # Riverpod TaskNotifier
│   │       ├── repositories/     # Supabase CRUD repository
│   │       └── ui/               # DashboardPage & TaskDetailPage
│   └── main.dart                 # App entry point & dependency initialization
├── pubspec.yaml                  # Dependencies & Flutter configuration
└── README.md
```

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology / Package |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart 3) |
| **Backend & Auth** | [Supabase Flutter](https://pub.dev/packages/supabase_flutter) |
| **State Management** | [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod) |
| **Routing** | [GoRouter](https://pub.dev/packages/go_router) |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) & [timezone](https://pub.dev/packages/timezone) |
| **E2E Automation** | [Maestro](https://maestro.mobile.dev) |

---

## 🗄️ Supabase Database Schema

To run DayForge with your own Supabase instance, create the `tasks` table with Row Level Security (RLS) enabled:

```sql
-- 1. Create tasks table
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  content text default '',
  created_at timestamptz not null default now(),
  reminder_at timestamptz
);

-- 2. Enable Row Level Security (RLS)
alter table public.tasks enable row level security;

-- 3. Create RLS policies for authenticated users
create policy "Users can view their own tasks"
  on public.tasks for select
  using (auth.uid() = user_id);

create policy "Users can insert their own tasks"
  on public.tasks for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own tasks"
  on public.tasks for update
  using (auth.uid() = user_id);

create policy "Users can delete their own tasks"
  on public.tasks for delete
  using (auth.uid() = user_id);
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13+ recommended)
- Java 17+ / Android SDK (Platform 34+)
- An active Android emulator or physical device connected via USB

### 1. Clone & Install Dependencies

```bash
# Clone the repository
git clone https://github.com/your-username/dayforge.git
cd dayforge

# Install Flutter packages
flutter pub get
```

### 2. Configure Supabase

Edit [`lib/config/supabase_config.dart`](file:///home/ardi/dayforge/lib/config/supabase_config.dart) with your Supabase credentials:

```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_PROJECT_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 3. Run the App

```bash
flutter run
```

> [!NOTE]
> Android requires **Core Library Desugaring** enabled for `flutter_local_notifications` (already configured in `android/app/build.gradle.kts` with `minSdk = 21` and `desugar_jdk_libs:2.1.4`).

---

## 🧪 Automated Testing with Maestro

DayForge includes UI and End-to-End automated testing flows configured in `.maestro/`.

### 1. Install Maestro CLI

```bash
curl -FsSL "https://get.maestro.mobile.dev" | bash
```

### 2. Run Test Flows

Start the app on your device/emulator, then run:

```bash
# Test Auth navigation & validation
maestro test .maestro/auth_navigation_flow.yaml

# Test Task creation, viewing, and editing
maestro test .maestro/task_management_flow.yaml

# Test Swipe-to-delete
maestro test .maestro/delete_task_flow.yaml

# Test Complete E2E journey with custom credentials
maestro test .maestro/e2e_flow.yaml \
  -e EMAIL="user@example.com" \
  -e PASSWORD="yourpassword"
```

### 3. Interactive Debugging

Use Maestro Studio to inspect UI elements live:

```bash
maestro studio
```

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
