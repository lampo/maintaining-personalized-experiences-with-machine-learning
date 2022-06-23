#!/bin/bash

set -euxvo pipefail

source /app/.venv/bin/activate
cd /app/source
pytest --cov