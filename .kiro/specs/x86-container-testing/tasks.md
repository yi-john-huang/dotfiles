# Implementation Tasks

## Feature: x86-container-testing
**Status**: Ready for Implementation
**Generated**: 2025-12-03T17:03:00.000Z

## Task Breakdown

### Phase 1: Core Utilities

#### Task 1.1: Create Colima utility functions
**File**: `lib/colima-utils.sh`
**Priority**: High
**Dependencies**: None
**Estimated Time**: 30 minutes

**Description**: Create shared utility functions for Colima profile management.

**Implementation**:
```bash
# Functions to implement:
- colima_profile_exists() - Check if profile exists
- colima_is_running() - Check if profile is running
- colima_get_arch() - Get architecture of running profile
```

**Acceptance Criteria**:
- [ ] Functions return correct exit codes (0=success, 1=failure)
- [ ] Uses existing lib/utils.sh for logging
- [ ] Handles case when Colima is not installed
- [ ] All functions have error handling

**Test Strategy**:
- Manual: Run functions with/without Colima installed
- Manual: Test with existing/non-existing profiles

---

#### Task 1.2: Create x86-start.sh script
**File**: `scripts/x86-start.sh`
**Priority**: High
**Dependencies**: Task 1.1
**Estimated Time**: 45 minutes

**Description**: Script to start Colima with x86_64 profile.

**Implementation**:
```bash
#!/usr/bin/env bash
# 1. Source lib/utils.sh and lib/colima-utils.sh
# 2. Check Colima installation
# 3. Check if x86 profile exists
#    - If no: colima start --profile x86 --arch x86_64 --cpu 2 --memory 4 --disk 10
#    - If yes: colima start --profile x86
# 4. Verify Docker context: docker context use colima-x86
# 5. Test: docker run --rm alpine uname -m (should output x86_64)
# 6. Display success message
```

**Acceptance Criteria**:
- [ ] Creates x86 profile on first run
- [ ] Starts existing x86 profile on subsequent runs
- [ ] Sets Docker context to colima-x86
- [ ] Verifies x86_64 architecture with test container
- [ ] Respects COLIMA_CPU, COLIMA_MEM, COLIMA_DISK env vars
- [ ] Displays clear success/error messages
- [ ] Idempotent (safe to run multiple times)

**Test Strategy**:
- Manual: Run on clean system (no x86 profile)
- Manual: Run when x86 profile already exists
- Manual: Run when x86 profile is already running
- Manual: Test with custom env vars

---

#### Task 1.3: Create x86-stop.sh script
**File**: `scripts/x86-stop.sh`
**Priority**: Medium
**Dependencies**: Task 1.1
**Estimated Time**: 20 minutes

**Description**: Script to stop x86_64 profile.

**Implementation**:
```bash
#!/usr/bin/env bash
# 1. Source utilities
# 2. Check if x86 profile is running
# 3. Stop: colima stop --profile x86
# 4. Display success message
```

**Acceptance Criteria**:
- [ ] Stops x86 profile if running
- [ ] Handles case when profile not running
- [ ] Displays clear messages
- [ ] Returns appropriate exit codes

**Test Strategy**:
- Manual: Stop running x86 profile
- Manual: Run when profile already stopped

---

### Phase 2: Docker Wrappers

#### Task 2.1: Create x86-build.sh script
**File**: `scripts/x86-build.sh`
**Priority**: High
**Dependencies**: Task 1.2
**Estimated Time**: 30 minutes

**Description**: Wrapper for docker build with x86_64 platform.

**Implementation**:
```bash
#!/usr/bin/env bash
# 1. Source utilities
# 2. Verify x86 profile is running (exit if not)
# 3. Execute: docker build --platform linux/amd64 "$@"
# 4. Display build summary
```

**Acceptance Criteria**:
- [ ] Checks x86 profile is running before build
- [ ] Passes all arguments to docker build
- [ ] Forces --platform linux/amd64
- [ ] Displays helpful error if profile not running
- [ ] Returns docker build exit code

**Test Strategy**:
- Manual: Build simple Dockerfile
- Manual: Run without x86 profile running
- Manual: Verify built image is x86_64

---

#### Task 2.2: Create x86-compose.sh script
**File**: `scripts/x86-compose.sh`
**Priority**: High
**Dependencies**: Task 1.2
**Estimated Time**: 30 minutes

**Description**: Wrapper for docker compose with x86_64 platform.

**Implementation**:
```bash
#!/usr/bin/env bash
# 1. Source utilities
# 2. Verify x86 profile is running
# 3. Set DOCKER_DEFAULT_PLATFORM=linux/amd64
# 4. Execute: docker compose "$@"
# 5. Display execution summary
```

**Acceptance Criteria**:
- [ ] Checks x86 profile is running
- [ ] Sets DOCKER_DEFAULT_PLATFORM
- [ ] Passes all arguments to docker compose
- [ ] Returns docker compose exit code

**Test Strategy**:
- Manual: Run simple docker-compose.yml
- Manual: Verify containers are x86_64

---

### Phase 3: Integration

#### Task 3.1: Update verify.sh
**File**: `verify.sh`
**Priority**: Medium
**Dependencies**: Task 1.1
**Estimated Time**: 20 minutes

**Description**: Add x86_64 capability verification.

**Implementation**:
```bash
# Add after Colima verification:
if command -v colima &> /dev/null; then
  info "Testing x86_64 emulation..."
  colima start --profile x86-test --arch x86_64 --cpu 1 --memory 1 --disk 5
  docker --context colima-x86-test run --rm alpine uname -m | grep -q x86_64
  colima delete --profile x86-test --force
  success "x86_64 emulation verified"
fi
```

**Acceptance Criteria**:
- [ ] Creates temporary test profile
- [ ] Verifies x86_64 architecture
- [ ] Cleans up test profile
- [ ] Doesn't interfere with existing profiles

**Test Strategy**:
- Manual: Run verify.sh on clean system
- Manual: Run with existing x86 profile

---

#### Task 3.2: Update README.md
**File**: `README.md`
**Priority**: Medium
**Dependencies**: All previous tasks
**Estimated Time**: 15 minutes

**Description**: Document x86_64 testing feature.

**Implementation**:
Add section after "Development Tools":
```markdown
## x86_64 Container Testing

Test containers on x86_64 architecture (useful for Apple Silicon):

### Start x86_64 environment
./scripts/x86-start.sh

### Build x86_64 image
./scripts/x86-build.sh -t myapp:x86 .

### Run docker-compose tests
./scripts/x86-compose.sh up

### Stop x86_64 environment
./scripts/x86-stop.sh

### Configuration
Override defaults with environment variables:
- COLIMA_CPU=4 (default: 2)
- COLIMA_MEM=8 (default: 4)
- COLIMA_DISK=20 (default: 10)
```

**Acceptance Criteria**:
- [ ] Clear usage examples
- [ ] Documents all scripts
- [ ] Explains configuration options
- [ ] Includes troubleshooting tips

---

### Phase 4: Testing & Validation

#### Task 4.1: Create test example
**File**: `examples/x86-test/`
**Priority**: Low
**Dependencies**: Phase 2
**Estimated Time**: 20 minutes

**Description**: Create example Dockerfile and compose file for testing.

**Implementation**:
```
examples/x86-test/
├── Dockerfile
├── docker-compose.yml
└── test-float.sh
```

**Acceptance Criteria**:
- [ ] Simple Dockerfile that builds on x86_64
- [ ] Compose file with test service
- [ ] Script that demonstrates float computation
- [ ] README with instructions

---

#### Task 4.2: Manual testing checklist
**File**: `.kiro/specs/x86-container-testing/testing.md`
**Priority**: Medium
**Dependencies**: All implementation tasks
**Estimated Time**: 30 minutes

**Description**: Execute full manual test suite.

**Test Cases**:
1. Fresh installation workflow
2. Profile switching (ARM64 → x86_64 → ARM64)
3. Build x86_64 image
4. Run compose with x86_64
5. Verify architecture in containers
6. Performance test (< 5 min startup)
7. Error scenarios
8. Idempotency tests

**Acceptance Criteria**:
- [ ] All test cases pass
- [ ] No errors in normal workflow
- [ ] Error messages are helpful
- [ ] Performance meets requirements

---

## Task Summary

**Total Tasks**: 9
**Estimated Time**: 4-5 hours

### By Priority
- High: 5 tasks (core functionality)
- Medium: 3 tasks (integration & docs)
- Low: 1 task (examples)

### By Phase
- Phase 1 (Core): 3 tasks
- Phase 2 (Wrappers): 2 tasks
- Phase 3 (Integration): 2 tasks
- Phase 4 (Testing): 2 tasks

## Implementation Order

1. Task 1.1 → 1.2 → 1.3 (Core utilities)
2. Task 2.1 → 2.2 (Docker wrappers)
3. Task 3.1 → 3.2 (Integration)
4. Task 4.1 → 4.2 (Testing)

## Success Criteria

- [ ] All scripts executable and working
- [ ] x86_64 containers run successfully
- [ ] Documentation complete
- [ ] Manual tests pass
- [ ] Performance < 5 minutes for full cycle
- [ ] No architecture-related bugs detected
