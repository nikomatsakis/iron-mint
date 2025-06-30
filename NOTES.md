# Iron Mint Design & Architecture

## Design Goals

Iron Mint aims to solve the "shell environment chaos" problem with these core principles:

1. **🏠 Familiar Shell Environment**: One script gives you a consistent look and feel (zsh, vi-like commands, preferred utilities like ripgrep)

2. **🔧 Project-Specific Tools**: Every project has its own config for build tools (rust 1.X, node 20, etc.) that works transparently

3. **⚙️ CI Consistency**: Easy to setup GitHub Actions that use the same tools as local development

4. **🔄 Local Reproducibility**: Easy to reproduce the CI environment locally for debugging

5. **🤝 Team-Friendly**: Project configuration doesn't force teammates onto intrusive workflows - uses standard files they already know

6. **🗂️ Centralized Configuration**: All Iron Mint config lives in `~/dev/iron-mint/` for easy management and version control

## Architecture Overview

**Two-Layer Design**:
- **Personal Layer (Iron Mint)**: Shell preferences, utilities, proto installation
- **Project Layer (proto)**: Language versions via standard files or `.prototools`

**Tool Specialization Strategy**:
- **Proto**: Coordinates most language versions, reads standard version files
- **Rustup**: Handles Rust (proto delegates to it, reads `rust-toolchain.toml`)
- **uv**: Recommended for Python dependency management (proto installs Python versions)

**PATH Layering**: proto tools → Iron Mint tools → system tools (preserves existing setup)

## Configuration Management

- **`~/.prototools`**: Symlinked to `~/dev/iron-mint/config/prototools` for centralized management
- **Shell integration**: Iron Mint's `multi-shrc` activates proto automatically
- **Backup system**: All changes backed up with timestamps, easy restoration

## Current Limitations

### Java Support
Proto does not currently support Java version management. This means:
- No automatic installation of different Java versions (OpenJDK, Corretto, etc.)
- Java projects will need to manage Java versions separately
- Consider alternatives:
  - Manual Java installation with JAVA_HOME management
  - SDKMAN for Java-heavy workflows
  - Hybrid approach: proto for most languages + separate Java tooling

## Future Considerations

### Java Integration Options
1. **Wait for proto Java plugin**: Monitor proto development for official Java support
2. **Custom proto plugin**: Consider creating a Java plugin for proto if needed
3. **Fallback to mise**: Keep mise as option specifically for Java projects
4. **External tooling**: Document how to use SDKMAN or manual Java management alongside proto

### Migration Path
If Java support becomes critical:
- Add conditional Java handling to Iron Mint
- Maintain proto for other languages
- Document mixed toolchain approach

## FAQ: Design Decisions

### Q: Why proto instead of mise?

**Decision**: Proto, despite being newer and having less language support (no Java).

**Reasoning**:
- **Philosophy alignment**: Proto delegates to expert tools (rustup for Rust) rather than reimplementing everything
- **Standard file support**: Proto reads `.nvmrc`, `.python-version` without extra configuration
- **Future-proofing**: Mise is moving away from idiomatic files ([2025.10.0 breaking change](https://github.com/jdx/mise/discussions/4345)), requiring explicit opt-in

**Trade-off**: Lost Java support, but gained better alignment with "use the right tool for each job" philosophy.

### Q: Why not use 100% Nix for everything?

**Decision**: Hybrid approach (Nix for personal tools, proto for project tools).

**Reasoning**:
- **Team adoption**: Nix has steep learning curve, would force workflow on teammates
- **Standards compatibility**: Projects can use `.nvmrc`, `.python-version` that teammates already understand
- **CI complexity**: Pure Nix requires teammates to learn Nix for CI contributions

**Trade-off**: Slightly slower CI (no perfect binary caching), but much better team collaboration.

### Q: Why not keep mise for some languages and proto for others?

**Decision**: Use proto as the single version manager coordinator.

**Reasoning**:
- **Consistent workflow**: One tool to learn and configure instead of switching between mise and proto
- **Reduced mental overhead**: Don't need to remember which tool manages which language
- **Simpler shell integration**: One activation command instead of multiple

**Trade-off**: Lost mise's broader language support (especially Java), but gained workflow consistency.

### Q: What about Python + uv complexity?

**Decision**: Proto manages Python versions AND installs uv/poetry as tools.

**Reasoning**:
- **Unified toolchain**: Proto installs Python, uv, and poetry, so all are available consistently
- **Project-level choice**: Projects still decide which package manager to use via their config files
- **No version conflicts**: Proto manages tool versions, projects choose which tools to use
- **Simpler than mise**: Avoids mise's [complex uv integration requirements](https://mise.jdx.dev/mise-cookbook/python.html)

**Trade-off**: Iron Mint installs both uv and poetry globally (small disk space), but projects can use either one.

### Q: Why symlink ~/.prototools instead of documenting the path?

**Decision**: Automatic symlink to `~/dev/iron-mint/config/prototools`.

**Reasoning**:
- **Centralized config**: Keeps all Iron Mint settings in one place
- **Version control**: Easy to track changes to your tool preferences
- **Backup integration**: Uses same backup/restore system as other dotfiles
- **Transparency**: Users can see and modify their global tool config easily

**Trade-off**: Slightly more complex install process, but much better organization.

### Q: Future plans for the nix-based CI action?

**Decision**: Separate project tracked in GitHub issue #1.

**Reasoning**:
- **MVP first**: Get the local development experience working before optimizing CI
- **Incremental improvement**: Can add CI optimization later without breaking local workflow
- **Option to explore**: Might build a tool that reads standard version files and generates optimal Nix expressions

**Current state**: Use proto in CI with GitHub Actions cache for reasonable performance.