# Per-Project Proto Setup Guide

This guide explains how to set up individual projects to use proto for tool version management, both in local development and CI/CD environments.

## Overview

**Iron Mint provides the foundation:**
- proto (the tool manager itself)
- Rust/rustup (since proto delegates to rustup)
- Java (since proto doesn't support Java well)

**Individual projects manage:**
- Node.js, Python, Go, and other language-specific tools via proto

## Project Setup

### 1. Create `.prototools` Configuration

Create a `.prototools` file in your project root to pin tool versions:

```toml
# .prototools - Project tool versions
node = "20.11.0"
npm = "10.2.4"
python = "3.12.0"
go = "1.21.5"

# Optional: Pin proto version for consistency
proto = "0.38.0"

[settings]
auto-install = true
auto-clean = true

[env]
# Project-specific environment variables
NODE_ENV = "development"
CARGO_TERM_COLOR = "always"
```

### 2. Install Project Tools

With Iron Mint active (which provides proto), install the project's tools:

```bash
# Install all tools defined in .prototools
proto use

# Or install specific tools
proto install node 20.11.0
proto install python 3.12.0
```

### 3. Verify Tool Availability

```bash
# Check installed versions
proto list

# Verify tools work
node --version
python --version
go version
```

## Development Workflow

### Daily Development

1. **Navigate to project directory** - Proto automatically detects `.prototools`
2. **Tools are automatically available** - No need to manually switch versions
3. **Install dependencies** using the pinned tool versions:
   ```bash
   npm install          # Uses pinned Node/npm versions
   pip install -r requirements.txt  # Uses pinned Python
   go mod download      # Uses pinned Go version
   ```

### Adding New Tools

```bash
# Add a new tool to the project
proto pin python 3.11.0    # Updates .prototools
proto use                   # Installs the new version
```

### Team Collaboration

1. **Commit `.prototools`** to version control
2. **Team members run** `proto use` after pulling changes
3. **Everyone gets identical tool versions** automatically

## GitHub Actions Setup

### Basic CI Configuration

Create `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup toolchain
        uses: moonrepo/setup-toolchain@v0
        with:
          auto-install: true
          cache: true

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Run linting
        run: npm run lint
```

### Multi-Language Project Example

For projects using multiple languages:

```yaml
name: Multi-Language CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: moonrepo/setup-toolchain@v0
        with:
          auto-install: true

      # All tools from .prototools are now available
      - name: Build Rust backend
        run: |
          cargo build --release
          cargo test

      - name: Build Node.js frontend
        run: |
          npm ci
          npm run build
          npm test

      - name: Run Python scripts
        run: |
          pip install -r requirements.txt
          python -m pytest
```

### Advanced CI Features

#### Matrix Builds with Multiple Tool Versions

```yaml
name: Matrix Testing
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: ['18.17.0', '20.11.0', '21.6.0']
    
    steps:
      - uses: actions/checkout@v4
      - uses: moonrepo/setup-toolchain@v0
        with:
          auto-install: true
      
      # Override the .prototools version for matrix testing
      - name: Use Node.js ${{ matrix.node-version }}
        run: proto install node ${{ matrix.node-version }}
      
      - run: npm ci
      - run: npm test
```

#### Caching Optimization

```yaml
- name: Setup toolchain with custom caching
  uses: moonrepo/setup-toolchain@v0
  with:
    auto-install: true
    cache: true
    cache-base: main  # Warm cache from main branch
    cache-version: v1 # Increment to invalidate cache
```

## Project Types and Examples

### Node.js Project

```toml
# .prototools
node = "20.11.0"
npm = "10.2.4"

[settings]
auto-install = true

[env]
NODE_ENV = "development"
```

### Python Project

```toml
# .prototools
python = "3.12.0"

[settings]
auto-install = true

[env]
PYTHONPATH = "src"
```

### Go Project

```toml
# .prototools
go = "1.21.5"

[settings]
auto-install = true

[env]
CGO_ENABLED = "0"
```

### Full-Stack Project

```toml
# .prototools
node = "20.11.0"
npm = "10.2.4"
python = "3.12.0"
go = "1.21.5"

[settings]
auto-install = true
auto-clean = true

[env]
NODE_ENV = "development"
PYTHONPATH = "backend/src"
CGO_ENABLED = "0"
```

## Best Practices

### Configuration Management

1. **Pin specific versions** rather than using ranges (e.g., `"20.11.0"` not `"~20"`)
2. **Commit `.prototools`** to ensure team consistency
3. **Update versions deliberately** as part of maintenance cycles
4. **Test version updates** in CI before merging

### Environment-Specific Configurations

For different environments, create additional config files:

```toml
# .prototools.production
node = "20.11.0"
npm = "10.2.4"

[settings]
auto-install = true
auto-clean = false  # Don't clean in production

[env]
NODE_ENV = "production"
```

Load with: `proto use --config .prototools.production`

### Monorepo Setup

For monorepos, use hierarchical configurations:

```
monorepo/
├── .prototools          # Root defaults
├── frontend/
│   └── .prototools      # Frontend-specific overrides
└── backend/
    └── .prototools      # Backend-specific overrides
```

### Troubleshooting

#### Common Issues

1. **Tools not found after `proto use`**
   - Ensure Iron Mint is active (provides proto)
   - Check that `.prototools` syntax is valid
   - Run `proto list` to see installed tools

2. **Version conflicts**
   - Use `proto clean` to remove unused versions
   - Check for conflicting global installations

3. **CI failures**
   - Verify `moonrepo/setup-toolchain@v0` is used (not deprecated `setup-proto`)
   - Ensure `.prototools` is committed to repository
   - Check GitHub Actions logs for proto installation errors

#### Debugging Commands

```bash
# Check proto status
proto --version
proto list

# Verify configuration
proto status

# Clean unused versions
proto clean

# Force reinstall tools
proto install --force
```

## Migration from Other Version Managers

### From nvm/fnm (Node.js)

1. Remove nvm/fnm from shell configuration
2. Create `.prototools` with desired Node version
3. Run `proto use` to install

### From pyenv (Python)

1. Note current Python version: `pyenv version`
2. Add to `.prototools`: `python = "3.12.0"`
3. Run `proto use`
4. Update CI to use `moonrepo/setup-toolchain@v0`

### From gvm (Go)

1. Check current Go version: `go version`
2. Add to `.prototools`: `go = "1.21.5"`
3. Run `proto use`

## Summary

This setup provides:
- ✅ **Consistent tool versions** across team and CI
- ✅ **Automatic tool switching** per project
- ✅ **Fast CI builds** with intelligent caching
- ✅ **Simple maintenance** through `.prototools` updates
- ✅ **Multi-language support** in single configuration

The combination of Iron Mint (providing proto, rust, java) and per-project proto configurations creates a robust, scalable development environment that works seamlessly from local development through production deployment.
