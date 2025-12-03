#!/usr/bin/env python3
import platform
import sys

print(f"Architecture: {platform.machine()}")
print(f"Platform: {platform.platform()}")

# Test floating point computation
a = 0.1 + 0.2
print(f"0.1 + 0.2 = {a}")
print(f"Exact representation: {a:.20f}")

# Test that we're on x86_64
if platform.machine() == "x86_64":
    print("✓ Running on x86_64")
    sys.exit(0)
else:
    print(f"✗ Expected x86_64, got {platform.machine()}")
    sys.exit(1)
