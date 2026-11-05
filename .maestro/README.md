# Maestro Test Automation for DayForge

Automated end-to-end and UI flows for DayForge (`com.example.dayforge`) using [Maestro](https://maestro.mobile.dev).

---

## 📁 Test Suite Structure

```
.maestro/
├── auth_navigation_flow.yaml   # Navigation between Login & Register, password validation
├── login_flow.yaml             # Login flow with environment credentials
├── task_management_flow.yaml   # Create entry, view detail, edit, and save
├── delete_task_flow.yaml       # Delete entry via swipe dismiss
├── e2e_flow.yaml               # Full end-to-end journey (Auth -> CRUD -> Logout)
├── subflows/
│   ├── login_subflow.yaml      # Reusable login flow
│   └── logout_subflow.yaml     # Reusable logout flow
└── README.md
```

---

## 🚀 Getting Started

### 1. Install Maestro CLI

```bash
curl -FsSL "https://get.maestro.mobile.dev" | bash
```

Verify installation:
```bash
maestro --version
```

### 2. Run the DayForge Application

Before running tests, ensure your Android emulator or iOS simulator is running and install DayForge:

```bash
flutter run
```

---

## 🧪 Running Maestro Flows

### Run a Single Flow
```bash
# Auth Navigation & Validation test
maestro test .maestro/auth_navigation_flow.yaml

# Task creation & editing test
maestro test .maestro/task_management_flow.yaml

# Swipe to delete test
maestro test .maestro/delete_task_flow.yaml
```

### Run with Custom Credentials
You can pass custom credentials dynamically via `-e`:
```bash
maestro test .maestro/login_flow.yaml \
  -e EMAIL="your_email@domain.com" \
  -e PASSWORD="your_secure_password"
```

### Run the Full End-to-End Suite
```bash
maestro test .maestro/e2e_flow.yaml \
  -e EMAIL="your_email@domain.com" \
  -e PASSWORD="your_secure_password"
```

### Run All Flows in Sequence
```bash
maestro test .maestro/
```

---

## 🛠️ Interactive Debugging with Maestro Studio

To inspect UI elements, test selectors, and record flows interactively in your browser:

```bash
maestro studio
```

