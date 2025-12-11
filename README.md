# NEBULA

![Lua](https://img.shields.io/badge/Lua-5.1%2B-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

**A mesmerizing terminal-based particle universe simulation.**

Watch galaxies form, black holes devour stars, and supernovas explode - all rendered in real-time in your terminal with physics-based particle effects.

## Features

*   **Spiral Galaxy:** Real-time orbital mechanics and galaxy formation.
*   **Black Hole:** Physics-based gravitational singularity.
*   **Supernova:** Explosive stellar death and expanding shockwaves.
*   **Matrix Rain:** Classic digital rain visualization.
*   **High Performance:** Optimized for 60 FPS smooth rendering.
*   **True Color:** Full RGB support via ANSI escape codes.

## Quick Start

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/nebula.git
    cd nebula
    ```

2.  **Run the simulation**
    ```bash
    lua nebula.lua
    ```

## Controls

| Key | Action |
| :--- | :--- |
| `1` | Switch to **Galaxy** Effect |
| `2` | Switch to **Black Hole** Effect |
| `3` | Switch to **Supernova** Effect |
| `4` | Switch to **Matrix** Effect |
| `Space` | Pause / Resume Simulation |
| `Q` | Quit |

## Configuration

You can adjust performance and visuals in `config.lua`:

*   **Resolution:** Auto-detects terminal size.
*   **FPS:** Cap the frame rate (default: 60).
*   **Particles:** Increase max particles for denser effects.
*   **Colors:** Change color palettes.

## Requirements

*   **Lua:** Version 5.1 or higher (LuaJIT is recommended for best performance).
*   **Terminal:** Must support ANSI escape codes and UTF-8.

