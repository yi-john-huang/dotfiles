# Technical Design Document

## Project: x86-container-testing

**Project Name:** Dotfiles
**Architecture:** Shell Scripts + Colima Configuration
**Language:** Bash

Generated on: 2025-12-03T16:54:00.249Z

## Architecture Overview

### System Architecture
Command-line tooling integrated with existing dotfiles bootstrap system, leveraging Colima for x86_64 container emulation on ARM64 hosts.

### Key Components
1. **Colima Profile Manager**: Manages x86_64 and ARM64 Colima profiles
2. **Docker Build Wrapper**: Ensures x86_64 platform flag for builds
3. **Docker Compose Wrapper**: Configures compose for x86_64 execution
4. **Convenience Scripts**: User-facing commands for workflow automation

### Integration Points
- `bootstrap.sh`: Already installs Colima
- `verify.sh`: Should verify x86_64 capability
- `lib/utils.sh`: Reuse logging and error handling

## Implementation Details

### Technology Stack
- **Shell**: Bash 4.0+
- **Container Runtime**: Colima (Lima + Docker)
- **Emulation**: QEMU (via Colima)
- **Docker**: Docker CLI + Docker Compose v2

### File Structure
```
.
├── scripts/
│   ├── x86-start.sh          # Start Colima with x86_64 profile
│   ├── x86-stop.sh           # Stop x86_64 profile
│   ├── x86-build.sh          # Build x86_64 images
│   └── x86-compose.sh        # Run compose with x86_64
└── lib/
    └── colima-utils.sh       # Shared Colima functions
```

## Component Design

### 1. Colima Profile Manager (`lib/colima-utils.sh`)

**Purpose**: Manage Colima profiles for different architectures

**Functions**:
```bash
colima_profile_exists(profile_name) -> bool
colima_is_running(profile_name) -> bool
colima_start_x86() -> exit_code
colima_stop_x86() -> exit_code
colima_switch_to_arm64() -> exit_code
```

**Implementation Notes**:
- Use `colima list` to check existing profiles
- Profile name: `x86` for x86_64, `default` for ARM64
- Configuration: 2 CPUs, 4GB RAM, 10GB disk (sufficient for local testing)
- Use inline flags, no config file needed

### 2. x86-start.sh

**Purpose**: Start Colima with x86_64 architecture

**Flow**:
```
1. Check if x86 profile exists
   ├─ No: Create with colima start --profile x86 --arch x86_64 --cpu 2 --memory 4 --disk 10
   └─ Yes: Start with colima start --profile x86
2. Verify Docker context is set to colima-x86
3. Test with: docker run --rm alpine uname -m
   └─ Should output: x86_64
4. Display success message with usage instructions
```

**Exit Codes**:
- 0: Success
- 1: Colima not installed
- 2: Failed to start profile

### 3. x86-stop.sh

**Purpose**: Stop x86_64 profile and optionally switch back to ARM64

**Flow**:
```
1. Check if x86 profile is running
   └─ No: Exit with message
2. Stop x86 profile: colima stop --profile x86
3. If --switch-to-arm64 flag: Start default profile
4. Display success message
```

### 4. x86-build.sh

**Purpose**: Build Docker images for x86_64 platform

**Usage**: `./scripts/x86-build.sh [docker build args]`

**Flow**:
```
1. Verify x86 profile is running
   └─ No: Prompt to run x86-start.sh
2. Execute: docker build --platform linux/amd64 "$@"
3. Tag image with -x86 suffix if -t flag present
4. Display build summary
```

### 5. x86-compose.sh

**Purpose**: Run docker-compose with x86_64 platform

**Usage**: `./scripts/x86-compose.sh [compose command]`

**Flow**:
```
1. Verify x86 profile is running
2. Set DOCKER_DEFAULT_PLATFORM=linux/amd64
3. Execute: docker compose "$@"
4. Display execution summary
```

## Configuration

### Environment Variables (Optional Overrides)
- `COLIMA_CPU`: CPU cores for x86 profile (default: 2)
- `COLIMA_MEM`: Memory in GB (default: 4)
- `COLIMA_DISK`: Disk size in GB (default: 10)
- `DOCKER_DEFAULT_PLATFORM`: Set to `linux/amd64` for x86_64 builds

## Integration with Bootstrap

### bootstrap.sh Changes
No changes needed - Colima already installed.

### verify.sh Additions
Add verification for x86_64 capability:
```bash
# Verify Colima can run x86_64
if command -v colima &> /dev/null; then
  info "Testing x86_64 emulation capability..."
  colima start --profile x86-test --arch x86_64 --cpu 1 --memory 1 --disk 5
  docker --context colima-x86-test run --rm alpine uname -m | grep -q x86_64
  colima delete --profile x86-test --force
fi
```

## Error Handling

### Common Errors
1. **Colima not installed**: Direct user to run bootstrap.sh
2. **Profile already running**: Offer to stop and restart
3. **QEMU emulation failure**: Check Rosetta 2 installation on macOS
4. **Docker context mismatch**: Auto-switch to correct context

### Logging
Reuse `lib/utils.sh` functions:
- `info()`: Normal operations
- `success()`: Successful completions
- `error()`: Failures with exit
- `warn()`: Non-fatal issues

## Testing Strategy

### Unit Tests (Manual)
1. Start x86 profile on clean system
2. Build simple Dockerfile with x86-build.sh
3. Run docker-compose with x86-compose.sh
4. Verify architecture with `uname -m` in container
5. Stop x86 profile and switch back to ARM64

### Integration Tests
1. Full workflow: start → build → compose → stop
2. Profile switching: ARM64 → x86_64 → ARM64
3. Error scenarios: missing Colima, failed builds

### Acceptance Tests
1. Float computation test: Build and run container with float operations
2. Performance test: Measure startup time < 5 minutes
3. Idempotency test: Run scripts multiple times

## Performance Considerations

### Startup Time
- Cold start (first time): ~2-3 minutes
- Warm start (profile exists): ~30 seconds
- Target: < 5 minutes for full test cycle

### Resource Usage
- CPU: 2 cores (configurable via COLIMA_CPU)
- Memory: 4GB (configurable via COLIMA_MEM)
- Disk: 10GB (configurable via COLIMA_DISK)

### Optimization
- Keep x86 profile running during development
- Use Docker layer caching
- Minimize image size for faster emulation

## Security Considerations

### Profile Isolation
- x86 and ARM64 profiles are isolated
- No shared volumes by default
- Separate Docker contexts

### Resource Limits
- CPU and memory limits prevent resource exhaustion
- Disk quota prevents filling host storage

## Documentation Updates

### README.md Additions
```markdown
## x86_64 Container Testing

Test containers on x86_64 architecture (useful for Apple Silicon):

# Start x86_64 environment
./scripts/x86-start.sh

# Build x86_64 image
./scripts/x86-build.sh -t myapp:x86 .

# Run docker-compose tests
./scripts/x86-compose.sh up

# Stop x86_64 environment
./scripts/x86-stop.sh
```

### Troubleshooting Section
- Rosetta 2 requirement on macOS
- QEMU performance tips
- Profile switching issues

## Future Enhancements (Out of Scope)
- Multi-architecture builds with buildx
- Automated CI/CD integration
- Performance profiling tools
- Windows/Linux host support
