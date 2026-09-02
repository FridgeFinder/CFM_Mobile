#!/usr/bin/env bash
set -euo pipefail

# Run iOS builds from a non-synced local path to avoid xattr/file-provider
# metadata that can break Xcode codesigning in simulator builds.

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAFE_ROOT="${HOME}/Developer"
SAFE_DIR="${SAFE_ROOT}/fridgefinder_flutter_ios_safe"
DEVICE_NAME="${1:-iPhone 17}"
APP_ENV_VALUE="${APP_ENV:-prod}"

if [[ "${APP_ENV_VALUE}" != "dev" && "${APP_ENV_VALUE}" != "prod" ]]; then
  echo "APP_ENV must be 'dev' or 'prod' (got: ${APP_ENV_VALUE})" >&2
  exit 1
fi

mkdir -p "${SAFE_ROOT}"

echo "Syncing project to safe build path..."
rsync -a --delete \
  --exclude '.git' \
  --exclude '.dart_tool' \
  --exclude 'build' \
  --exclude 'ios/Pods' \
  --exclude 'ios/.symlinks' \
  "${SRC_DIR}/" "${SAFE_DIR}/"

cd "${SAFE_DIR}"

echo "Installing dependencies..."
flutter pub get

echo "Launching on ${DEVICE_NAME} with APP_ENV=${APP_ENV_VALUE}..."
flutter run -d "${DEVICE_NAME}" --dart-define="APP_ENV=${APP_ENV_VALUE}"
