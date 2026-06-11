#!/bin/bash
set -euo pipefail

if [ ! -f profiles.yml ]; then
    cp profiles.example.yml profiles.yml
    echo "Created profiles.yml from profiles.example.yml"
fi

if command -v dbt >/dev/null 2>&1; then
    DBT_CMD="dbt"
elif [ -x ".venv/bin/dbt" ]; then
    DBT_CMD=".venv/bin/dbt"
else
    echo "dbt command not found. Install dependencies with: uv pip install -r requirements.txt"
    exit 127
fi

"${DBT_CMD}" seed --profiles-dir .
"${DBT_CMD}" run --profiles-dir .
"${DBT_CMD}" test --profiles-dir .
