# Circuit STEM

![Circuit STEM Banner](https://user-images.githubusercontent.com/1296468/269848727-e3d72b33-5783-4043-80a7-051b5133a05c.png)

An engaging and educational puzzle game built with Flutter, designed to teach the fundamentals of electrical circuits in a fun, hands-on way.

---

## ✨ Features

*   **Interactive Puzzles:** Drag, drop, and rotate components to build working circuits.
*   **Real Logic:** A pure-Dart logic engine accurately simulates power flow, open circuits, and shorts.
*   **Level Progression:** Advance through a series of increasingly challenging levels, with progress saved automatically.
*   **Data-Driven:** Levels are loaded from simple JSON files, making it easy to add new content.
*   **Clean Architecture:** Built with a modular, service-oriented architecture for maintainability and scalability.

## 🚀 Getting Started

1.  Ensure you have the Flutter SDK installed.
2.  Clone the repository:
    ```sh
    git clone https://github.com/your-username/circuit_stem.git
    ```
3.  Navigate to the project directory and install dependencies:
    ```sh
    cd circuit_stem
    flutter pub get
    ```
4.  Run the app:
    ```sh
    flutter run
    ```

## 🏛️ Architecture

The project follows a clean, modular architecture that separates logic, state management, and UI.

*   **Services (`/lib/services`):** Stateless, reusable services like the `LogicEngine` and `LevelManager`.
*   **Engine (`/lib/engine`):** The `GameEngine` orchestrates the state and rules for an active game session.
*   **Models (`/lib/models`):** Plain Dart objects representing the game's data, such as `Grid`, `Component`, and `LevelDefinition`.
*   **UI (`/lib/ui`):** Flutter widgets, screens, and `CustomPainter`s responsible for rendering the game state.

For a complete overview of the technical design, please see the **[Technical Requirements Document (TRD)](./DOCS/TRD.md)**.

## 📚 Documentation

This project is documented using the following standards. All documents can be found in the `/DOCS` directory.

*   **[📄 Business Requirements (BRD)](./DOCS/BRD.md):** High-level goals, vision, and scope of the project.
*   **[📄 Functional Requirements (FRD)](./DOCS/FRD.md):** Detailed descriptions of what the application does from a user's perspective.
*   **[📄 Technical Requirements (TRD)](./DOCS/TRD.md):** A deep dive into the technical architecture, components, and data flow.

---

*This README was updated to reflect the new modular architecture. The previous, highly-detailed content was split into the formal documents linked above.*
