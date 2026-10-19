# Linux Setup

[![CI](https://github.com/acp9191/linux-setup/actions/workflows/ci.yml/badge.svg)](https://github.com/acp9191/linux-setup/actions/workflows/ci.yml)

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
* **Automatic updates** — unattended-upgrades for Ubuntu, Docker, and Tailscale packages
* **Security** — key-only SSH and a firewall that only allows SSH over Tailscale
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
9. Enables automatic package and tool updates
10. Hardens SSH and enables the firewall
11. Links Git and GPG configuration

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
* Automatic updates and the weekly tool update timer are enabled
* The firewall is enabled and SSH is key-only
* Repository-managed dotfiles are correctly symlinked
* mise configuration is correctly symlinked
* Git commit signing is enabled
* GitHub CLI is authenticated

A successful check looks like:

```text
Shell & Terminal
  ✓ Zsh                  installed
  ✓ tmux                 installed
  ✓ fzf                  installed
  ...

Languages
  ✓ Go                   1.27.2 linux/amd64
  ✓ Node                 24.22.0
  ✓ Python               3.14.8

Containers
  ✓ Docker               29.9.1
  ✓ Compose              5.5.1
  ✓ Docker access        without sudo

System
  ✓ Auto updates         enabled
  ✓ Tool updates         weekly
  ✓ SSH                  key-only logins
  ✓ Firewall             enabled

Configuration
  ✓ .zshrc               linked
  ✓ .gitconfig           linked
  ✓ GPG signing          enabled
  ✓ GitHub CLI auth      authenticated

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
├── apt/
│   ├── 20auto-upgrades
│   └── 52unattended-upgrades-local
├── ssh/
│   └── 10-linux-setup.conf
├── systemd/
│   ├── linux-setup-update.service
│   └── linux-setup-update.timer
├── packages/
│   └── apt.txt
├── scripts/
│   ├── install-auto-updates.sh
│   ├── install-bun.sh
│   ├── install-docker.sh
│   ├── install-mise.sh
│   ├── install-opencode.sh
│   ├── install-security.sh
│   ├── install-tailscale.sh
│   ├── install-update-timer.sh
│   ├── install-uv.sh
│   ├── install-zsh.sh
│   └── lib.sh
├── check.sh
├── install.sh
├── update.sh
├── .github/workflows/ci.yml
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

## Automatic Updates

`install.sh` configures [unattended-upgrades](https://help.ubuntu.com/community/AutomaticSecurityUpdates) so apt packages update themselves daily in the background:

* Ubuntu security **and** regular updates (`-security`, `-updates`)
* Docker and Tailscale from their apt repositories
* Unused kernels and dependencies are removed afterwards
* If an update requires a restart, the machine **reboots automatically at 04:00** (system time, UTC by default)

The configuration lives in `apt/` and is copied into `/etc/apt/apt.conf.d/`. To disable automatic reboots, set `Unattended-Upgrade::Automatic-Reboot "false";` in `apt/52unattended-upgrades-local` and re-run `./install.sh`.

Preview what would be upgraded:

```bash
sudo unattended-upgrade --dry-run --debug
```

Logs are written to `/var/log/unattended-upgrades/`.

Ubuntu release upgrades (e.g. 24.04 → 26.04) are never applied automatically; run `sudo do-release-upgrade` deliberately when you're ready. ESM Apps updates require an [Ubuntu Pro](https://ubuntu.com/pro) subscription (`sudo pro attach`); once attached, they are picked up automatically.

### Developer tools

Tools installed outside apt are updated **weekly** by a systemd user timer that runs `./update.sh --unattended`:

* mise, uv, Bun, and OpenCode self-updates
* uv-installed tools
* Oh My Zsh and its plugins

The scheduled run skips apt (already handled above) and `mise upgrade`, so runtime versions such as a new Node LTS major are only changed when you run `./update.sh` yourself. It runs as your user, not root, and lingering is enabled so it runs while you are logged out. Missed runs are caught up at the next boot.

See past runs and the next scheduled one:

```bash
journalctl --user -u linux-setup-update
systemctl --user list-timers linux-setup-update.timer
```

Run it now, or turn it off:

```bash
systemctl --user start linux-setup-update.service
systemctl --user disable --now linux-setup-update.timer
```

## Security

`install.sh` hardens the machine in two steps, each guarded so it can't lock you out:

* **Key-only SSH.** Password and root password logins are disabled via `/etc/ssh/sshd_config.d/10-linux-setup.conf`. This is skipped until `~/.ssh/authorized_keys` contains a key.
* **Tailscale-only firewall.** `ufw` denies all incoming traffic except over the `tailscale0` interface (plus Tailscale's UDP port 41641), so SSH is no longer reachable on the public IP. This is skipped until `sudo tailscale up` has connected the machine, and when the current SSH session came in over the public internet.

On a fresh VM, connect Tailscale, reconnect over SSH using the machine's Tailscale address, and re-run `./install.sh` to enable the firewall.

If you are ever locked out, use your cloud provider's web console and run `sudo ufw disable`.

> Docker-published ports (`docker run -p 8080:80`) bypass `ufw` and are reachable publicly. Bind them to localhost or the Tailscale IP instead, e.g. `-p 127.0.0.1:8080:80`.

## Continuous Integration

GitHub Actions runs on every push and pull request:

* **ShellCheck** lints every script.
* **Install** runs `./install.sh` twice on a fresh `ubuntu-24.04` runner (the second run confirms it is idempotent), then `./check.sh`, then starts the weekly update service to confirm it works under systemd.

## Updating

The environment can be updated with:

```bash
./update.sh
```

This updates:

* Ubuntu packages
* mise itself
* mise-managed runtimes
* uv and uv-installed tools
* Bun
* OpenCode
* Oh My Zsh
* Zsh plugins

`./update.sh --unattended` runs only the tool updates (no sudo, apt, or `mise upgrade`); it is what the weekly timer runs.

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

### uv

```bash
uv self update
uv tool upgrade --all
```

### Bun

```bash
bun upgrade
```

`bun upgrade` updates the Bun runtime itself; `bun update` updates a project's dependencies.

### OpenCode

```bash
opencode upgrade
```

### Oh My Zsh

```bash
omz update
```

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

