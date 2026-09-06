# 606VD // Violence District 2026

> **Status:** Operational // Private Compiled Build  
> **Target Game:** Violence District  
> **Architecture:** Modern Luau Native Engine  

---

## Universal Loadstring (Roblox Executor)

Paste and execute this one-liner in your executor (Solara, Wave, Codex, Delta, Fluxus, etc.):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/1rxc/606VD/main/606VD.lua"))()
```

---

## Features

### Combat Protocols
- **Auto Parry (Killer Only)**: Multi-layer detection triggering exclusively against genuine attacks from the true match killer.
- **Facing Angle Verification**: Configurable 360-degree parry defense against spins and flicks.

### Killer Protocols (Killer Only)
- **Anti Stun**: Instant immunity and rapid recovery from pallet stuns, flashlight blinding, and ragdoll states.
- **Fast Speed Boost**: Directional physics assist with adjustable velocity rate (18 - 55 studs/s).
- **Role Detection Filter**: Automatically limits combat buffs to the Killer role.

### Automation
- **Smart Great Fix Gen**: Self-calibrated sweet spot (106 to 119 deg) with zero manual adjustment needed.
- **Auto Repair Assist**: Hands-free generator progression.

### Visuals (ESP)
- **Killer ESP**: 3D character bounding box and dynamic billboard indicator.
- **Player ESP**: Survivor distance, health, and status indicators.
- **Generator ESP**: Physical 3D highlight and live percentage completion tags.
- **Exit & Hatch ESP**: 3D spatial highlights on escape gates and trapdoors.

### UI & Performance
- **Zero UIStroke Lag-Free Design**: 1px custom border frames for ultra-smooth FPS.
- **Clean GTA 6 Cyberpunk Aesthetic**: High-contrast luxury theme with minimize `[-]` and close `[X]` controls.
- **Hotkeys**: Toggle UI with `RightControl` or `V`.
