# Arcanum Novus — Modern Engine & UI Modernization for Arcanum

Arcanum Novus is an open-source engine modernization, high-resolution UI renderer, and modern operating system compatibility layer for *Arcanum: Of Steamworks and Magick Obscura*. Built around a **Vulkan 1.3 and DirectX 12 (Feature Level 12_1) First/Only** graphics rendering architecture and C++20, Arcanum Novus brings modern display resolution support, 60 FPS UI rendering, improved pathfinding, and native Linux/Windows support to Troika's classic RPG.

---

## ⚡ Core Subsystems & Status Matrix

| Subsystem | Features & Capabilities | Status / Roadmap |
|---|---|---|
| **Graphics Engine** | **Vulkan 1.3 & DirectX 12 (Feature Level 12_1) First/Only** hardware viewport | Active |
| **High-Res Renderer** | Modern Widescreen & 4K display rendering, UI scaling engine, high-DPI scaling | Active |
| **Interface Smoothing** | Custom UI skin support, vector font rendering, 60 FPS UI animation interpolation | Roadmap |
| **Engine Core** | 64-bit address space stability, multi-core CPU fixes, memory leak resolution | Active |
| **Party AI & Modding** | Multi-threaded asset loader, improved party AI pathfinding, extended modding API hooks | Roadmap |
| **Input & Quality-of-Life**| Customizable hotkeys, raw mouse input, mouse wheel zoom | Active |
| **Controller Support** | Native gamepad / Steam Deck input mapping, quick-loot interface | Roadmap |

---

## ⚙️ Key Features & Engine Improvements

### 🖥️ High-Resolution Renderer & UI Scaling (`engine/ui`)
- **Current**: Modern Widescreen & 4K display resolution rendering, UI scaling engine, borderless windowed mode, and high-DPI scaling.
- **Planned / Roadmap**: Custom UI skin support, vector font rendering, and 60 FPS interface animation smoothing.

### 🛠️ Engine Bugfixes & Pathfinding (`engine/core`)
- **Current**: Memory leak fixes, modern Windows 11/Linux compatibility, 64-bit address space stability, and multi-core CPU fixes.
- **Planned / Roadmap**: Improved party AI pathfinding, multi-threaded asset loading, and expanded modding API hooks.

### 🎮 Controls & Quality-of-Life (`engine/input`)
- **Current**: Customizable hotkeys, raw mouse input handling, and mouse wheel zoom.
- **Planned / Roadmap**: Native controller / Steam Deck input mapping and quick-loot interface.

---

## 🏗️ Architecture & Technology Stack

- **Graphics APIs**: Vulkan 1.3 & DirectX 12 (Feature Level 12_1) First/Only.
- **Platforms**: Windows (MSVC / MinGW), Linux (GCC / Clang).
- **Core Language**: C++20 core engine.
- **Licensing**: AGPL-3.0.

---

## 🛠️ Building & Running

### Windows
```bat
build.bat Release
run.bat
```

### Linux
```bash
./prepare-source.sh
./build.linux.sh
```

---

## 📜 License & Disclaimers

Arcanum Novus is licensed under the **GNU Affero General Public License v3.0** (AGPL-3.0). See [`LICENSE`](LICENSE) for details. *Arcanum: Of Steamworks and Magick Obscura* is the property of its respective copyright holders; Arcanum Novus is an independent fan modernization project and requires original game assets to play.
