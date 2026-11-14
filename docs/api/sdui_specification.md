# Server-Driven UI (SDUI) & Dynamic Configuration Specification

## 1. Architectural Philosophy
Server-Driven UI allows the Super Admin and authorized School Administrators to remotely modify screen layouts, component ordering, feature visibility, and dynamic navigation without releasing a new Android APK or deploying frontend code changes.

```
+-----------------------------------------------------------+
|               Global Platform Configuration               |
|                           ↓                               |
|              Subscription Plan Entitlements               |
|                           ↓                               |
|           School Tenant Overrides (if permitted)          |
|                           ↓                               |
|              User Role (Student / Teacher / Parent)        |
+-----------------------------------------------------------+
```

---

## 2. SDUI Component Registry

The Flutter mobile application and web portals render only components explicitly validated against the component registry:

| Component Type | Purpose | Supported Attributes |
|---|---|---|
| `welcome_banner` | Greets user with school motto and session | `title`, `subtitle`, `badge` |
| `attendance_card` | Displays today's presence, check-in time, and MTD rate | `title`, `liveSync` |
| `routine_strip` | Shows upcoming class period, teacher, and room number | `title`, `showCountdown` |
| `result_card` | Highlights latest examination GPA and letter grade | `title`, `term` |
| `fee_summary_card` | Shows outstanding tuition dues with quick payment CTA | `title`, `paymentChannel` |
| `notice_list` | Recent circulars with urgent alert priority badges | `title`, `limit` |
| `quick_actions` | Shortcut action grid (Routine, Results, Fees, Digital ID) | `actions` |

---

## 3. Schema Example (JSON Payload)

```json
{
  "screenId": "student_home",
  "version": 2,
  "title": "Dhaka Model School Student Portal",
  "components": [
    {
      "id": "comp_welcome",
      "type": "welcome_banner",
      "visible": true,
      "order": 1,
      "title": "Welcome, Tahmid Rahman",
      "subtitle": "Class 10 • Roll #1"
    },
    {
      "id": "comp_quick_actions",
      "type": "quick_actions",
      "visible": true,
      "order": 2
    },
    {
      "id": "comp_attendance",
      "type": "attendance_card",
      "visible": true,
      "order": 3,
      "title": "Today's Attendance Status"
    },
    {
      "id": "comp_routine",
      "type": "routine_strip",
      "visible": true,
      "order": 4,
      "title": "Today's Class Timetable"
    },
    {
      "id": "comp_result",
      "type": "result_card",
      "visible": true,
      "order": 5,
      "title": "First Term Examination 2026"
    },
    {
      "id": "comp_fees",
      "type": "fee_summary_card",
      "visible": true,
      "order": 6,
      "title": "Tuition Fee Status"
    },
    {
      "id": "comp_notices",
      "type": "notice_list",
      "visible": true,
      "order": 7,
      "title": "School Notice Board"
    }
  ]
}
```

---

## 4. Security & Isolation Safeguards
1. **No Code Execution**: Neither Dart nor JavaScript code is executed dynamically. Components map to strict pre-compiled Flutter and React widget factories.
2. **Schema Validation**: Every payload submitted to `/api/sdui/publish` is validated against `sduiScreenLayoutSchema` via Zod before persistence.
3. **Draft & Versioning**: Every publish creates an immutable version snapshot with rollback capability.
4. **Offline Fallback**: When offline or if configuration fails to load, clients immediately fall back to the last-known-good cached layout stored in local storage.
