# Per-Project Development Tool Setup Guide

This guide explains how to set up individual projects with native tool version management using standard ecosystem tools.

## Overview

**Iron Mint provides the foundation:**
- rustup (Rust toolchain management)
- volta (Node.js version management)
- uv (Python package management)
- Standard development tools

**Individual projects manage:**
- Tool versions through native configuration files (rust-toolchain.toml, .nvmrc/.node-version, pyproject.toml, etc.)

## Project Setup

### 1. Node.js Projects - Use Volta

Create a `.node-version` or `.nvmrc` file to pin Node.js version:

```bash
# .node-version
20.11.0
```

Install with volta:
```bash
# Pin Node.js version for this project
volta pin node@20.11.0
volta pin npm@10.2.4
```

### 2. Python Projects - Use uv

Create a `pyproject.toml` to specify Python version:

```toml
[project]
requires-python = ">=3.12"

[tool.uv]
python = "3.12.0"
```

### 3. Rust Projects - Use rustup

Create a `rust-toolchain.toml` file:

```toml
[toolchain]
channel = "stable"
# Or specific version: channel = "1.75.0"
```

### 4. Verify Tool Availability

```bash
# Check installed versions
node --version    # Uses volta-managed version
python --version  # Uses uv-managed version  
rustc --version   # Uses rustup-managed version
```

## Development Workflow

### Daily Development

1. **Navigate to project directory** - Tools automatically detect version files
2. **Tools switch versions automatically** - rustup uses `rust-toolchain.toml`, volta uses `.node-version`, uv uses `pyproject.toml`
3. **Install dependencies** using the detected tool versions:
   ```bash
   npm install          # Uses volta-managed Node/npm versions
   uv pip install -r requirements.txt  # Uses uv-managed Python
   cargo build          # Uses rustup-managed Rust version
   ```

### Adding New Tools

```bash
# Pin Node.js version for project
volta pin node@20.11.0

# Set Python version in pyproject.toml
# [tool.uv]
# python = "3.12.0"

# Set Rust toolchain
echo 'stable' > rust-toolchain
# or create rust-toolchain.toml with specific version
```

### Team Collaboration

1. **Commit version files** (`.node-version`, `pyproject.toml`, `rust-toolchain.toml`) to version control
2. **Team members automatically get correct versions** when using rustup/volta/uv
3. **No manual sync required** - tools detect project requirements automatically

## GitHub Actions Setup

### Node.js Projects with Volta

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

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version-file: '.node-version'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Run linting
        run: npm run lint
```

### Multi-Language Project Example

For projects using Rust + Node.js:

```yaml
name: Multi-Language CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Rust
        uses: dtolnay/rust-toolchain@stable
        # Automatically reads rust-toolchain.toml if present

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version-file: '.node-version'
          cache: 'npm'

      - name: Build Rust backend
        run: |
          cargo build --release
          cargo test

      - name: Build Node.js frontend
        run: |
          npm ci
          npm run build
          npm test
```

### Python Projects with uv

```yaml
name: Python CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version-file: 'pyproject.toml'

      - name: Install uv
        run: pip install uv

      - name: Install dependencies
        run: uv pip install -r requirements.txt

      - name: Run tests
        run: python -m pytest
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
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - run: npm ci
      - run: npm test
```

#### Dependency Caching

```yaml
- name: Setup Node.js with caching
  uses: actions/setup-node@v4
  with:
    node-version-file: '.node-version'
    cache: 'npm'
    cache-dependency-path: 'package-lock.json'
```

## Project Types and Examples

### Node.js Project

```bash
# .node-version
20.11.0
```

```json
// package.json
{
  "engines": {
    "node": ">=20.11.0",
    "npm": ">=10.2.4"
  }
}
```

### Python Project

```toml
# pyproject.toml
[project]
requires-python = ">=3.12"

[tool.uv]
python = "3.12.0"
```

### Rust Project

```toml
# rust-toolchain.toml
[toolchain]
channel = "stable"
# Or: channel = "1.75.0"
```

### Full-Stack Project

```bash
# .node-version (for frontend)
20.11.0
```

```toml
# rust-toolchain.toml (for backend)
[toolchain]
channel = "stable"
```

```toml
# pyproject.toml (for scripts/ML components)
[project]
requires-python = ">=3.12"

[tool.uv]
python = "3.12.0"
```

## Best Practices

### Configuration Management

1. **Pin specific versions** in version files for reproducibility
2. **Commit version files** (`.node-version`, `pyproject.toml`, `rust-toolchain.toml`) to ensure team consistency
3. **Update versions deliberately** as part of maintenance cycles
4. **Test version updates** in CI before merging

### Environment-Specific Configurations

For different environments, create separate files:

```bash
# .node-version.production
20.11.0
```

```toml
# pyproject.production.toml
[tool.uv]
python = "3.12.0"
```

### Monorepo Setup

For monorepos, use native tool detection:

```
monorepo/
├── .node-version        # Global Node.js version
├── frontend/
│   └── .nvmrc          # Frontend-specific Node version
└── backend/
    └── rust-toolchain.toml  # Backend Rust version
```

### Troubleshooting

#### Common Issues

1. **Tools not found**
   - Ensure rustup/volta/uv are installed
   - Check version files are in project root
   - Verify PATH includes tool directories

2. **Version conflicts**
   - Use native tool commands to see active versions (`node --version`, `rustc --version`)
   - Check for conflicting global installations

3. **CI failures**
   - Verify correct GitHub Actions are used (`actions/setup-node@v4`, `dtolnay/rust-toolchain@stable`)
   - Ensure version files are committed to repository

#### Debugging Commands

```bash
# Check active versions
node --version
python --version  
rustc --version

# Check tool paths
which node
which python
which rustc

# Check version files
cat .node-version
cat pyproject.toml
cat rust-toolchain.toml
```

## Migration from Other Version Managers

### From nvm/fnm (Node.js)

1. Note current Node version: `node --version`
2. Install volta: `curl https://get.volta.sh | bash`
3. Create `.node-version` with current version
4. Remove nvm/fnm from shell configuration

### From pyenv (Python)

1. Note current Python version: `python --version`
2. Install uv: `pip install uv`
3. Create `pyproject.toml` with current version
4. Remove pyenv from shell configuration

### From proto (Any language)

1. Note current versions: `proto list`
2. Install native tools (rustup, volta, uv)
3. Create appropriate version files
4. Remove proto configuration and shell integration

## Summary

This setup provides:
- ✅ **Consistent tool versions** across team and CI
- ✅ **Automatic tool switching** per project using native toolchain detection
- ✅ **Fast CI builds** with standard GitHub Actions
- ✅ **Simple maintenance** through standard version files
- ✅ **Ecosystem compatibility** using each language's preferred tools

Using rustup, volta, and uv directly provides better ecosystem integration, clearer mental models, and fewer layers of abstraction while maintaining the same project-specific version management benefits.
