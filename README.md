
Master Godot tutorial, tanks @Brackeys for this material
https://www.youtube.com/watch?v=LOhfqjmasi0

# Multiplayer Game with Godot Engine

This repository contains a **multiplayer game** developed using the **Godot Engine**. The project demonstrates advanced networking capabilities, including server-client architecture, player synchronization, and unique gameplay mechanics for different character types.

---

## Features

### Multiplayer
- **Server-Client Architecture:** The game supports hosting and joining via ENet networking.
- **Player Synchronization:** Utilizes `MultiplayerSynchronizer` and `MultiplayerSpawner` for smooth synchronization of player actions and movements.
- **Authority Management:** Proper handling of server authority and client control using `set_multiplayer_authority`.

### Gameplay
- **Generic Player Class:** A base `Player` class implements shared movement and multiplayer logic, extended by specific character classes (`ArcherPlayer`, `KnightPlayer`) for unique abilities.
- **Custom Animations:** Smooth transitions between `idle`, `run`, `jump`, and `attack` animations, with logic to return to the appropriate state after an action.

### Code Architecture
- Modular and scalable.
- Signals (`animation_finished`) are utilized for clean transitions between animations.
- Error-handling and debug logging implemented for networking and gameplay.

---

## Getting Started

### Prerequisites
- **Godot Engine:** Version 4.0 or higher.
- **Git:** For cloning the repository.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/your-repo.git
   cd your-repo
   ```
2. Open the project in Godot Engine.
3. Run the project by pressing F5 or clicking the Play button.

---

## Usage

### Hosting a Server
- Start the game, and it will automatically attempt to host a server if no server is found.

### Joining as a Client
- Configure the `SERVER_IP` and `SERVER_PORT` variables in the `join_as_player_2()` method.
- Join by running the client instance.

---

## Code Overview

### Key Classes

#### `Player`
- Handles:
  - Generic player movements (walking, jumping).
  - Multiplayer synchronization via `MultiplayerSynchronizer`.
  - Animation logic for state transitions.

#### `ArcherPlayer` and `KnightPlayer`
- Extends the `Player` class.
- Implements unique combat mechanics for each character.

### Key Methods

#### `_apply_animations()`
- Ensures animations transition seamlessly.

#### `_apply_movement_from_input(delta)`
- Handles movement and inputs, including jump and attack logic.

#### `_on_animation_finished()`
- Returns to the appropriate idle or movement animation after an attack is completed.

---

## Common Issues & Debugging

### Multiplayer Connection
- **Error:** `cannot find property "rcp" on base Callable godot`
  - Ensure that the `@rpc` decorator is applied correctly to your methods.

- **Error:** `Condition "!sync || !sync->get_replication_config_ptr() || !_has_authority(sync)" is true`
  - Ensure all nodes using `MultiplayerSynchronizer` are instantiated properly on both server and client.

### Animations
- **Issue:** Attack animation doesn't return to the correct state.
  - Verify the `animation_finished` signal is connected properly.
  - Use `CONNECT_ONESHOT` to prevent duplicate signal connections.

---

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Acknowledgments
- **Godot Engine Documentation**: For detailed guidance on multiplayer systems.
- The Godot community for support and inspiration.
