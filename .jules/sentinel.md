## 2024-05-23 - [Mobile App Access Control Bypass]
**Vulnerability:** The `InventoryManagementScreen` was accessible to any authenticated user via the Settings screen because there was no role check on the navigation button or within the screen itself.
**Learning:** Relying on security through obscurity (hiding buttons) is insufficient. Even mobile apps need explicit Role-Based Access Control (RBAC) checks in logic/screens, especially when deep linking or state manipulation is possible.
**Prevention:** Always verify user privileges (`role == 'admin'`) before rendering sensitive UI elements and within the `initState` or build method of sensitive screens.
