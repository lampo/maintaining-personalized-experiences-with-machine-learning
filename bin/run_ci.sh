#!/bin/bash

set -euxvo pipefail

cd /app/source
/app/.venv/bin/pytest --cov