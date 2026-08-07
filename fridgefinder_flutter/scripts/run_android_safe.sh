#!/usr/bin/env bash
set -euo pipefail

# Run Android with an explicit environment to avoid accidental prod/dev mixups.

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE_NAME="${1:-android}"
APP_ENV_VALUE="${APP_ENV:-dev}"

if [[ "${APP_ENV_VALUE}" != "dev" && "${APP_ENV_VALUE}" != "prod" ]]; then
  echo "APP_ENV must be 'dev' or 'prod' (got: ${APP_ENV_VALUE})" >&2
  exit 1
fi

cd "${PROJECT_DIR}"

echo "Running on ${DEVICE_NAME} with APP_ENV=${APP_ENV_VALUE}..."
flutter run -d "${DEVICE_NAME}" --dart-define="APP_ENV=${APP_ENV_VALUE}"
