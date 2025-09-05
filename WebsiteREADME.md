# Ckochx

A modern, lightweight web server built with Elixir, featuring static file serving and a flat-file blog system. Built on top of Plug and Bandit for maximum performance and reliability.

## Features

- **Static File Serving** - Efficiently serve CSS, JS, images, and other assets
- **Flat-File Blog** - Markdown and HTML blog posts with frontmatter metadata
- **Modern UI** - Responsive design with Tailwind CSS and dark/light themes
- **Hot Reloading** - Development-friendly with automatic code reloading
- **High Performance** - Built on Elixir/OTP for massive concurrency
- **Zero Configuration** - Works out of the box

## Quick Start

### Prerequisites

- [Elixir](https://elixir-lang.org/install.html) 1.18+ 
- [Erlang/OTP](https://www.erlang.org/) 26+

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ckochx
```

2. Install dependencies:
```bash
mix deps.get
```

3. Start the development server:
```bash
mix dev
```

4. Visit http://localhost:4000

## Development

### Hot Reloading

The development server includes hot reloading for:
- `.ex` and `.exs` files (Elixir code)
- `.md` and `.html` files (blog posts)
- Static assets in `priv/static/`

Start with hot reloading:
```bash
mix dev
```

### Production

Build and deploy production releases:
```bash
# Build release
./scripts/build_release.sh [version]

# Initial deployment
./scripts/deploy.sh user@server 0.1.0 deploy

# Hot upgrade (zero downtime)
./scripts/deploy.sh user@server 0.2.0 upgrade

# Rollback if needed
./scripts/deploy.sh user@server 0.1.0 rollback
```

## Project Structure

```
ckochx/
├── lib/
│   ├── ckochx/
│   │   ├── application.ex      # OTP application
│   │   ├── web_server.ex       # Plug router & templates  
│   │   ├── blog.ex            # Blog post parser
│   │   └── dev_reloader.ex    # Hot reloading (dev only)
│   └── mix/tasks/dev.ex       # Development task
├── priv/
│   ├── static/                # Static assets (HTML, CSS, JS)
│   └── blog/posts/           # Blog posts (.md, .html)
└── test/                     # Test files
```

## Blog System

### Adding Blog Posts

Create `.md` or `.html` files in `priv/blog/posts/`:

**Markdown Example (`my-post.md`):**
```markdown
---
title: "My Blog Post"
date: "2024-01-15"  
author: "Your Name"
excerpt: "A brief description"
---

# Hello World

Your **markdown** content here!
```

**HTML Example (`my-post.html`):**
```html
<!--
title: "My HTML Post"
date: "2024-01-15"
author: "Your Name"  
excerpt: "A brief description"
-->

<h1>Hello World</h1>
<p>Your <strong>HTML</strong> content here!</p>
```

### Blog Routes

- `GET /blog` - Blog index with all posts
- `GET /blog/:slug` - Individual blog post (slug = filename without extension)

## Tech Stack

- **[Elixir](https://elixir-lang.org/)** - Functional programming language
- **[Plug](https://github.com/elixir-plug/plug)** - Web application interface  
- **[Bandit](https://github.com/mtrudel/bandit)** - HTTP server
- **[Earmark](https://github.com/pragdave/earmark)** - Markdown parser
- **[Tailwind CSS](https://tailwindcss.com/)** - Utility-first CSS framework

## Deployment & Hot Upgrades

Ckochx supports zero-downtime deployments using Erlang/OTP's hot code swapping capabilities.

### Building Releases

```bash
# Build production release
./scripts/build_release.sh

# Build specific version
./scripts/build_release.sh 0.2.0
```

This creates a self-contained release tarball with all dependencies.

### Deployment Options

#### Initial Deployment
```bash
# Deploy to server for the first time
./scripts/deploy.sh user@myserver.com 0.1.0 deploy
```

This will:
- Set up the release directory structure
- Configure systemd service
- Start the application

#### Hot Upgrades (Zero Downtime)
```bash
# Upgrade running application without stopping
./scripts/deploy.sh user@myserver.com 0.2.0 upgrade
```

Hot upgrades:
- ✅ Zero downtime - users stay connected
- ✅ Automatic rollback on failure
- ✅ Health checks during upgrade
- ✅ Preserves application state

#### Rollback
```bash
# Rollback to previous version
./scripts/deploy.sh user@myserver.com 0.1.0 rollback
```

### Environment Configuration

Set these environment variables in production:

- `PORT` - HTTP server port (default: 4000)
- `LOG_LEVEL` - Logging level (debug/info/warn/error)
- `HOST` - Server hostname
- `MIX_ENV=prod` - Production environment

### Monitoring & Operations

```bash
# Check service status
systemctl status ckochx

# View logs
journalctl -u ckochx -f

# Connect to running application
/opt/ckochx/bin/ckochx remote

# Execute commands remotely
/opt/ckochx/bin/ckochx rpc "Ckochx.UpgradeManager.current_version()"
```

### Hot Upgrade Manager

The `Ckochx.UpgradeManager` provides:
- Automatic upgrade detection
- Manual upgrade triggering
- Health monitoring during upgrades
- Rollback capabilities
- Version management

Enable automatic upgrades:
```elixir
config :ckochx,
  enable_hot_upgrades: true,
  auto_upgrade: true,
  upgrade_check_interval: 30_000
```

## License

This project is open source and available under the [MIT License](LICENSE).

