#!/usr/bin/env bash
set -euo pipefail

if [[ "${APP_ENV:-}" != "prod" ]]; then
  echo "Refusing to run production lane without APP_ENV=prod." >&2
  echo "Current APP_ENV='${APP_ENV:-<unset>}'" >&2
  exit 1
fi

echo "APP_ENV=prod check passed."
