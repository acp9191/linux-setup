# Linux Setup

Reproducible Ubuntu development environment setup.

This repository contains my personal configuration and provisioning scripts for setting up a fresh Linux development machine. The goal is simple: **clone the repo, run one command, and get back to a familiar environment.**

## What's Included

* **Ubuntu packages** — common CLI and development utilities
* **Zsh** — Zsh with Oh My Zsh, autosuggestions, and syntax highlighting
* **tmux** — terminal multiplexer with Vim-style navigation
* **zoxide** — smarter directory navigation
* **uv** — Python package and project management
* **Bun** — JavaScript/TypeScript runtime and package manager
* **mise** — runtime version management

  * Node.js LTS
  * Python 3.14
  * Go
* **Tailscale** — private networking between machines
* **OpenCode** — AI coding agent
* **Git** — global Git configuration and aliases
* **GPG** — Git commit signing configuration
* **Dotfiles** — shell, tmux, Git, and GPG configuration managed from the repository

## Quick Start

Clone the repository:

```bash
git clone https://github.com/acp9191/linux-setup.git
cd linux-setup
```

Run the installer:

```bash
./install.sh
```

The installer is designed to be **idempotent**, so it can safely be run again when provisioning an existing machine.

## What `install.sh` Does

The setup is organized into a few layers:

1. Installs system packages from `packages/apt.txt`
2. Installs and configures Zsh
3. Links shell and tmux configuration
4. Installs development tools
5. Configures mise and installs declared runtimes
6. Installs Tailscale
7. Installs OpenCode
8. Links Git and GPG configuration

Machine-specific authentication and credentials are intentionally kept outside the repository.

For example, Tailscale is installed automatically, but joining a tailnet is a separate step:

```bash
sudo tailscale up
```

## Repository Structure

```text
linux-setup/
├── home/
│   ├── .gitconfig
│   ├── .tmux.conf
│   ├── .zshrc
│   └── .gnupg/
│       └── gpg-agent.conf
├── mise/
│   └── config.toml
├── packages/
│   └── apt.txt
├── scripts/
│   ├── install-bun.sh
│   ├── install-mise.sh
│   ├── install-opencode.sh
│   ├── install-tailscale.sh
│   ├── install-uv.sh
│   ├── install-zsh.sh
│   └── lib.sh
├── install.sh
├── .gitignore
└── README.md
```

## Runtime Versions

Runtime versions are managed by [mise](https://mise.jdx.dev/).

Current configuration:

```toml
[tools]
go = "latest"
node = "lts"
python = "3.14"
```

This keeps the repository declarative while allowing mise to resolve and install the appropriate versions.

## Updating

Different parts of the environment have different update mechanisms.

### Ubuntu packages

```bash
sudo apt update
sudo apt upgrade
```

### mise

Update mise itself:

```bash
mise self-update
```

Update installed mise-managed tools as desired:

```bash
mise upgrade
```

### uv tools

```bash
uv tool upgrade --all
```

### Bun packages

```bash
bun update
```

### Oh My Zsh

```bash
omz update
```

The bootstrap script is intentionally focused on **provisioning**, not upgrading everything on the machine. Updates should be performed explicitly.

## Configuration Philosophy

This repository separates **portable configuration** from **machine-specific state**.

### Tracked

* Shell configuration
* Git configuration
* tmux configuration
* GPG agent configuration
* Package lists
* Runtime versions
* Installation scripts

### Not tracked

* Private keys
* API keys
* Passwords
* Tailscale authentication state
* Other machine-specific credentials

Configuration files in `home/` are symlinked into `$HOME`, keeping the repository as the source of truth.

## Fresh Machine

The ultimate test for this repository is a completely fresh Ubuntu VM.

```bash
git clone https://github.com/acp9191/linux-setup.git
cd linux-setup
./install.sh
```

After installation, authenticate machine-specific services such as Tailscale and configure any credentials required by development tools.

---

Personal Linux environment, automated and reproducible.

