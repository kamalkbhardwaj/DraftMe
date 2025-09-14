# DraftMe

A SwiftUI app targeting iOS with a lightweight MVI (Model–View–Intent) architecture.

- Target OS: iOS 17+
- Language/UI: Swift 5.9+, SwiftUI
- Architecture: MVI with unidirectional data flow

## Architecture

- View: Renders `State`, forwards events to `Intent`.
- Intent: Maps UI events to actions; triggers `Model` work.
- Model: Business logic, side-effects (network, storage), emits new `State`.
- State: Single source of truth consumed by the View.

## Folder Hierarchy

```
DraftMe/
  Sources/
    App/                    # App entry, DI, AppState bootstrap
    Core/
      Store/                # State types, reducer/side-effects helpers
      Networking/           # API clients, DTOs
      Persistence/          # Local storage (Keychain/CoreData/UserDefaults)
      DesignSystem/         # Reusable styles/components/modifiers
    Features/
      Home/
        View/               # SwiftUI views
        Intent/             # Actions, intent handlers
        Model/              # Use cases, services, mocks
        State/              # ViewState, domain models
      Settings/
    Resources/              # Assets, strings, fonts
  Tests/
    ...                     # Unit/UI tests per feature
```

## Build & Run

- Open in Xcode 15+ and run on an iOS 17+ simulator or device.

> If your target OS differs (e.g., iPadOS or macOS), adjust the Target OS line and any platform-specific modules accordingly.

