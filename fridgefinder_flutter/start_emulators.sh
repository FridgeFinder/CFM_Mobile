#!/bin/bash

# Start Firebase Emulator Suite for testing
# This script starts the Auth, Database, and Functions emulators

echo "Starting Firebase Emulator Suite..."
echo "Auth Emulator: http://127.0.0.1:9099"
echo "Database Emulator: http://127.0.0.1:9000"
echo "Functions Emulator: http://127.0.0.1:5001"
echo "Emulator UI: http://127.0.0.1:4000"
echo ""
echo "Press Ctrl+C to stop the emulators"

firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
