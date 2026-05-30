#!/usr/bin/env python3
import json
import os
from pathlib import Path

# Read env.json and create .env file
env_file = Path("env.json")
env_output = Path(".env")

if env_file.exists():
    with open(env_file, 'r') as f:
        data = json.load(f)

    with open(env_output, 'w') as f:
        for key, value in data.items():
            f.write(f"{key}={value}\n")

    print(f"✓ Created {env_output} from {env_file}")
else:
    print(f"✗ {env_file} not found")
