# x86_64 Container Test Example

Simple example to test x86_64 container execution on Apple Silicon.

## Usage

### Build and run with x86-build.sh
```bash
cd examples/x86-test
../../scripts/x86-build.sh -t x86-test:latest .
docker run --rm x86-test:latest
```

### Build and run with x86-compose.sh
```bash
cd examples/x86-test
../../scripts/x86-compose.sh up --build
```

## Expected Output
```
Architecture: x86_64
Platform: Linux-6.x.x-x86_64-with-glibc2.x
0.1 + 0.2 = 0.30000000000000004
Exact representation: 0.30000000000000004441
✓ Running on x86_64
```
