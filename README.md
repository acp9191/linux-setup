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
* **Docker** — container runtime and Compose
* **OpenCode** — AI coding agent
* **Git** — global Git configuration, aliases, and delta
* **GitHub CLI** — GitHub access from the terminal
* **GPG** — Git commit signing configuration
* **direnv** — automatic project-specific environment variables
* **Dotfiles** — shell, tmux, Git, mise, and GPG configuration managed from the repository

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

After installation, verify the environment:

```bash
./check.sh
```

## What `install.sh` Does

The setup is organized into a few layers:

1. Installs system packages from `packages/apt.txt`
2. Installs and configures Zsh
3. Links shell and tmux configuration
4. Installs development tools
5. Configures mise and installs declared runtimes
6. Installs Tailscale
7. Installs Docker and Docker Compose
8. Installs OpenCode
9. Links Git and GPG configuration

Machine-specific authentication and credentials are intentionally kept outside the repository.

For example, Tailscale is installed automatically, but joining a tailnet is a separate step:

```bash
sudo tailscale up
```

GitHub CLI authentication is also performed separately:

```bash
gh auth login
```

## Checking the Environment

`check.sh` verifies that the environment is both **installed and configured correctly**.

Run:

```bash
./check.sh
```

Checks include:

* Required CLI tools are installed
* Go, Node.js, and Python are available through mise
* Docker and Docker Compose are available
* Docker works without `sudo`
* OpenCode is installed
* Repository-managed dotfiles are correctly symlinked
* mise configuration is correctly symlinked
* Git commit signing is enabled
* GitHub CLI is authenticated

A successful check looks like:

```text
Shell & Terminal
  ✓ Zsh                installed
  ✓ tmux               installed
  ✓ fzf                installed
  ...

Languages
  ✓ Go                 go1.27.1 linux/amd64
  ✓ Node               v24.20.0
  ✓ Python             3.14.7

Containers
  ✓ Docker             installed
  ✓ Compose             5.5.1
  ✓ Docker access      without sudo

Configuration
  ✓ .zshrc             configured
  ✓ .gitconfig         configured
  ✓ .tmux.conf         configured
  ✓ mise config        configured
  ✓ GPG signing        enabled
  ✓ GitHub CLI         authenticated

────────────────────────────────────────
✓ All checks passed
```

The check exits with a non-zero status if any required component or configuration is missing, making it useful for validating a fresh machine after provisioning.

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
│   ├── install-docker.sh
│   ├── install-mise.sh
│   ├── install-opencode.sh
│   ├── install-tailscale.sh
│   ├── install-uv.sh
│   ├── install-zsh.sh
│   └── lib.sh
├── check.sh
├── install.sh
├── update.sh
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

The environment can be updated with:

```bash
./update.sh
```

This updates:

* Ubuntu packages
* mise itself
* mise-managed runtimes
* uv-installed tools
* Oh My Zsh
* Zsh plugins

Individual components can also be updated manually when appropriate.

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

Update installed mise-managed tools:

```bash
mise upgrade
```

### uv tools

```bash
uv tool upgrade --all
```

### Oh My Zsh

```bash
omz update
```

Bun is intentionally not updated by `update.sh` because `bun update` operates on a project's dependencies rather than updating the Bun runtime itself.

The update script is intentionally focused on the tools managed by this repository. Project-specific dependencies should be updated within their respective projects.

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
* GitHub authentication state
* Other machine-specific credentials

Configuration files in `home/` and `mise/` are symlinked into the appropriate locations, keeping the repository as the source of truth.

## Fresh Machine

The ultimate test for this repository is a completely fresh Ubuntu VM.

```bash
git clone https://github.com/acp9191/linux-setup.git
cd linux-setup
./install.sh
./check.sh
```

After installation, authenticate machine-specific services such as Tailscale and GitHub CLI, then run the checks again:

```bash
./check.sh
```

The goal is for a fresh machine to end with:

```text
✓ All checks passed
```

---

Personal Linux environment, automated and reproducible.

