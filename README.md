# dotfiles

Personal developer dotfiles for a WSL2 environment on Windows. Sets up a full terminal-first development workflow with Bash, Neovim, Docker, and a suite of modern TUI tools.

---

## System Requirements

| Requirement | Details |
|---|---|
| **OS** | Windows 10 (Build 19041+) or Windows 11 |
| **WSL** | WSL2 (not WSL1) |
| **Distro** | Ubuntu 22.04+ |
| **Architecture** | x86\_64 (AMD64) |
| **Windows Terminal** | Recommended — needed for font and theme support |
| **VS Code** | Optional — for editor integration via `code .` in WSL |

---

## WSL Setup

Run all of the following from **PowerShell as Administrator** on Windows.

### 1. Enable WSL2

```powershell
wsl --install
```

Reboot when prompted.

### 2. Install Ubuntu

```powershell
wsl --install -d Ubuntu
```

Alternatively, install Ubuntu from the Microsoft Store. Launch it once to complete setup and create your Unix username and password.

### 3. Set WSL2 as default

```powershell
wsl --set-default-version 2
```

### 4. Configure WSL networking

This repo includes a `.wslconfig` that enables mirrored networking — required for LAN device access (e.g. testing on a physical phone with Expo).

Copy it to your Windows user profile directory:

```powershell
Copy-Item "\\wsl$\Ubuntu\home\<your-unix-user>\.dotfiles\.wslconfig" "$env:USERPROFILE\.wslconfig"
```

Or create `C:\Users\<YourUsername>\.wslconfig` manually with:

```ini
[wsl2]
networkingMode=mirrored
```

> [!NOTE]
> This file must exist **before** WSL starts. Restart WSL after placing it: `wsl --shutdown` then relaunch.

---

## Windows Setup

### Windows Terminal — Vesper color scheme

1. Open Windows Terminal → Settings → **Open JSON file** (bottom-left)
2. Find the `"schemes"` array and paste in the contents of [`dots/windows-terminal/Vesper.json`](dots/windows-terminal/Vesper.json)
3. Go to your Ubuntu profile → Appearance → Color scheme → select **Vesper**

### Windows Terminal — Font

After running the dotfiles setup (see below), the Cascadia Code Nerd Font is installed automatically on both WSL and Windows.

Set it in Windows Terminal:

1. Ubuntu profile → Appearance → Font face → `CascadiaCode NF`
2. Save

### Expo / React Native networking (optional)

If you develop React Native apps with Expo from WSL2 and need to test on a physical device over LAN, run the setup script from **PowerShell as Administrator**:

```powershell
.\expo-setup-wsl2.ps1
```

This script:
- Sets your active WiFi network profile to **Private**
- Enables the **IP Helper** service (required for port proxying)
- Creates port proxy rules forwarding ports `8081`, `19000`, `19001`, `19002` from Windows to WSL2
- Adds Windows Firewall inbound rules for those ports

---

## Fonts

The dotfiles setup installs **Cascadia Code Nerd Font** automatically (via `install/12-cascadia-code.sh`), so no manual font installation is needed if you run `setup.sh`.

For reference, the script:
- Installs all TTF variants to `~/.local/share/fonts/CascadiaCode/` inside WSL
- Installs the `CascadiaCodeNF` variants to `%LOCALAPPDATA%\Microsoft\Windows\Fonts\` on Windows (no admin rights required)
- Runs `fc-cache -fv` to register the fonts in Linux

The font provides Nerd Font glyphs used by the shell prompt and TUI tools like `eza`.

---

## Setup

> [!IMPORTANT]
> Run this inside WSL (Ubuntu), not from Windows PowerShell.

### 1. Clone the repo

```bash
git clone https://github.com/<your-username>/.dotfiles ~/.dotfiles
cd ~/.dotfiles
```

### 2. Run the setup script

```bash
./setup.sh
```

The script will prompt you for your **Git name** and **email**, then run everything automatically.

### What it installs

| Step | What it does |
|---|---|
| Base tools | `curl`, `git`, `wget`, `unzip`, `gpg` |
| Dev libraries | `build-essential`, `clang`, `rustc`, OpenSSL, readline, zlib, SQLite, and more |
| [mise](https://mise.jdx.dev/) | Runtime version manager — installs Node.js LTS |
| Docker | Engine, CLI, Compose plugin, Buildx plugin, rootless setup |
| TUI apps | `fzf`, `ripgrep`, `bat`, `eza`, `zoxide`, `btop`, `fd`, `fastfetch`, `gum` |
| [Neovim](https://neovim.io/) | Latest release + [LazyVim](https://lazyvim.github.io/) starter config |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for Git |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | Terminal UI for Docker |
| [GitHub CLI](https://cli.github.com/) | `gh` command + `gh-dash` extension |
| [zellij](https://zellij.dev/) | Terminal multiplexer (auto-launches with the shell), configured with the built-in Vesper theme |
| Cascadia Code NF | Nerd Font for WSL and Windows |
| Dotfiles | Symlinks all configs in `dots/` to `~`, backing up any existing files |
| Git config | Global aliases and settings configured |

---

## What's Included

### Shell (Bash)

- Custom prompt with Nerd Font arrow glyph
- History: 32k entries, deduplication enabled
- Arrow key history search
- Case-insensitive tab completion
- [zoxide](https://github.com/ajeetdsouza/zoxide) smart `cd` replacement (`z` command)
- [fzf](https://github.com/junegunn/fzf) key bindings (`Ctrl+R` for history, `Ctrl+T` for files)
- pnpm and mise on PATH
- zellij auto-launches when opening a terminal, themed with the built-in Vesper color scheme

### Aliases

| Alias | Command |
|---|---|
| `n` | `nvim` |
| `g` | `git` |
| `d` | `docker` |
| `lzg` | `lazygit` |
| `lzd` | `lazydocker` |
| `zj` | `zellij` |
| `ls`, `lsa`, `lt` | `eza`-based listing |
| `ff` | `fzf` with file preview |
| `bat` | `bat` (syntax-highlighted cat) |
| `..` / `...` / `....` | Directory shortcuts |
| `gcm` | `git commit -m` |
| `gcam` | `git commit -am` |
