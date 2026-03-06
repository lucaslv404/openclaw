---
summary: "Install OpenClaw in an isolated environment on Windows (WSL2 + Docker) with a dedicated data directory"
read_when:
  - You want to run OpenClaw on Windows with isolation from your default profile
  - You already have WSL2 and Docker Desktop and want a contained setup
  - You want to understand isolation level and risks for this setup
title: "Windows (isolated)"
---

# OpenClaw on Windows (isolated)

This guide describes installing OpenClaw in an **isolated** environment on Windows using WSL2 and Docker: config and workspace live in a **dedicated directory** (not your default `~/.openclaw`), and you can optionally enable agent sandboxing for tool execution isolation.

Related:

- Standard Windows install: [Windows (WSL2)](/platforms/windows)
- Docker workflow: [Docker](/install/docker)
- Security model: [Security](/gateway/security)

## When to use this

- You want OpenClaw on Windows **without** touching your default `~/.openclaw` (or you want a second, disposable instance).
- You already have **WSL2** and **Docker Desktop** (with WSL2 backend).
- You are comfortable running bash and Docker from inside WSL.

## Prerequisites

- **WSL2** (Ubuntu recommended). Install: `wsl --install` (see [Microsoft WSL install](https://learn.microsoft.com/windows/wsl/install)).
- **Docker Desktop** with the WSL2 engine enabled. All commands below run **inside a WSL terminal**, not in PowerShell/CMD.

## Steps

### 1) Open a WSL terminal

Use your default WSL distro (e.g. Ubuntu). Ensure Docker is running (Docker Desktop starts the engine for WSL2).

### 2) Clone the repo (if needed)

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
```

### 3) Set an isolated data directory and run the Docker setup

Use a directory **inside WSL** (e.g. under `$HOME`) so config and workspace are not in your default `~/.openclaw`:

```bash
export OPENCLAW_CONFIG_DIR="$HOME/openclaw-isolated/.openclaw"
export OPENCLAW_WORKSPACE_DIR="$HOME/openclaw-isolated/.openclaw/workspace"
./docker-setup.sh
```

Optional: enable **agent sandbox** so non-main sessions run tools inside a separate Docker container:

```bash
export OPENCLAW_CONFIG_DIR="$HOME/openclaw-isolated/.openclaw"
export OPENCLAW_WORKSPACE_DIR="$HOME/openclaw-isolated/.openclaw/workspace"
export OPENCLAW_SANDBOX=1
./docker-setup.sh
```

The script will build the image (or pull if `OPENCLAW_IMAGE` is set), run onboarding, and start the gateway. It creates the config and workspace directories under `$HOME/openclaw-isolated/.openclaw`.

### 4) Use OpenClaw

- Open the Control UI: `http://127.0.0.1:18789/` (from Windows or WSL).
- For CLI usage, always **export the same env vars** so Compose uses the same paths:

```bash
export OPENCLAW_CONFIG_DIR="$HOME/openclaw-isolated/.openclaw"
export OPENCLAW_WORKSPACE_DIR="$HOME/openclaw-isolated/.openclaw/workspace"
docker compose run --rm openclaw-cli <command>
```

To get a fresh dashboard URL: `docker compose run --rm openclaw-cli dashboard --no-open`.

## Isolation level

| Dimension | Level | Notes |
|-----------|--------|--------|
| **Process / runtime** | High | Gateway and CLI run inside a container. With sandbox enabled, tools run in a separate container, isolated from the host. |
| **Filesystem** | Medium–high | Config and workspace live in a **dedicated** WSL directory; your default `~/.openclaw` is unused. WSL and Windows can still access each other’s files (e.g. `\\wsl$\...` from Windows). |
| **Network** | Medium | Default `gateway.bind=lan` limits access to localhost/LAN. Risk is low if you do not expose the gateway to the internet. |
| **Credentials / secrets** | Medium | Stored under the config directory; anyone who can read that directory (including via Windows mount of WSL) effectively has gateway access. |

**Boundaries not covered:** Docker escape, cross-access between WSL2 and Windows, supply chain (image and dependencies), and any process on the host that can read the bind-mounted config directory.

## Risks and best practices

- **Docker escape:** A compromised container or image could theoretically escape to the host (here, WSL2). Mitigate by using the official or a trusted image and keeping images and dependencies updated.
- **WSL2 ↔ Windows access:** Windows can access WSL files via `\\wsl$\<distro>\...`. For stronger isolation, avoid mounting or opening the isolated data directory from Windows.
- **Bind mounts:** Config and workspace are readable by any process on the host (WSL) with access to that path. Do not share the directory with untrusted apps.
- **Network exposure:** If you expose the gateway port to the internet, follow [Security](/gateway/security) (binding, firewall, authentication).
- **Supply chain:** Prefer the official image and pinned dependencies; keep images and lockfiles updated.

Best practices:

- Do not expose the gateway to the public internet unless you harden it (see [Security](/gateway/security)).
- Do not share the isolated config/workspace directory with untrusted applications.
- Use the official image (`ghcr.io/openclaw/openclaw`) or a local build from the official repo.
- Run `openclaw security audit` (from the CLI container with the same env) periodically if you use this setup for sensitive workloads.

## See also

- [Windows (WSL2)](/platforms/windows) — standard install on Windows
- [Docker](/install/docker) — full Docker Compose options (mounts, sandbox, remote image)
- [Security](/gateway/security) — trust model, binding, and hardening
