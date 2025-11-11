#!/bin/bash
# FridgeFinder Test Runner Script
# Usage: ./scripts/run_tests.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
EMULATOR_RUNNING=false
VERBOSE=false
COVERAGE=false
TEST_FILE=""
TEST_NAME=""

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

print_error() {
    echo -e "${RED}✗ ${NC}$1"
}

# Function to check if Firebase emulator is running
check_emulator() {
    if lsof -Pi :9099 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to start Firebase emulator
start_emulator() {
    print_info "Starting Firebase emulator..."

    # Check if already running
    if check_emulator; then
        print_warning "Firebase emulator is already running"
        EMULATOR_RUNNING=true
        return 0
    fi

    # Start emulator in background
    firebase emulators:start --only auth,database > /tmp/firebase-emulator.log 2>&1 &
    EMULATOR_PID=$!

    # Wait for emulator to start (max 30 seconds)
    print_info "Waiting for emulator to start..."
    for i in {1..30}; do
        if check_emulator; then
            print_success "Firebase emulator started (PID: $EMULATOR_PID)"
            EMULATOR_RUNNING=true
            return 0
        fi
        sleep 1
    done

    print_error "Failed to start Firebase emulator"
    cat /tmp/firebase-emulator.log
    return 1
}

# Function to stop Firebase emulator
stop_emulator() {
    if [ "$EMULATOR_RUNNING" = true ]; then
        print_info "Stopping Firebase emulator..."

        # Kill processes on emulator ports
        lsof -ti:9099 | xargs kill -9 2>/dev/null || true
        lsof -ti:9000 | xargs kill -9 2>/dev/null || true
        lsof -ti:5001 | xargs kill -9 2>/dev/null || true
        lsof -ti:4000 | xargs kill -9 2>/dev/null || true

        print_success "Firebase emulator stopped"
    fi
}

# Function to run tests
run_tests() {
    print_info "Running tests..."

    # Build test command
    local cmd="flutter test"

    if [ "$VERBOSE" = true ]; then
        cmd="$cmd --reporter expanded"
    fi

    if [ "$COVERAGE" = true ]; then
        cmd="$cmd --coverage"
    fi

    if [ -n "$TEST_NAME" ]; then
        cmd="$cmd --name \"$TEST_NAME\""
    fi

    if [ -n "$TEST_FILE" ]; then
        cmd="$cmd $TEST_FILE"
    else
        cmd="$cmd test/integration/"
    fi

    # Run tests
    print_info "Executing: $cmd"
    if eval "$cmd"; then
        print_success "All tests passed!"

        # Generate coverage report if requested
        if [ "$COVERAGE" = true ]; then
            print_info "Generating coverage report..."
            if command -v genhtml &> /dev/null; then
                genhtml coverage/lcov.info -o coverage/html
                print_success "Coverage report generated at coverage/html/index.html"
            else
                print_warning "genhtml not found. Install lcov to generate HTML coverage report."
            fi
        fi

        return 0
    else
        print_error "Some tests failed"
        return 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    local missing=false

    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found. Please install Flutter SDK."
        missing=true
    else
        print_success "Flutter: $(flutter --version | head -n 1)"
    fi

    # Check Firebase CLI
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI not found. Install with: npm install -g firebase-tools"
        missing=true
    else
        print_success "Firebase CLI: $(firebase --version)"
    fi

    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js not found. Please install Node.js."
        missing=true
    else
        print_success "Node.js: $(node --version)"
    fi

    if [ "$missing" = true ]; then
        print_error "Missing prerequisites. Please install required software."
        exit 1
    fi

    print_success "All prerequisites satisfied"
}

# Function to display usage
usage() {
    cat <<EOF
FridgeFinder Test Runner

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Verbose test output
    -c, --coverage          Generate coverage report
    -f, --file FILE         Run specific test file
    -n, --name NAME         Run tests matching name
    -s, --skip-emulator     Skip starting Firebase emulator
    --check                 Check prerequisites only

EXAMPLES:
    # Run all integration tests
    $0

    # Run specific test file
    $0 -f test/integration/signup_integration_test.dart

    # Run tests with coverage
    $0 -c

    # Run tests matching name
    $0 -n "SU-001"

    # Verbose output
    $0 -v

    # Check prerequisites
    $0 --check

EOF
}

# Parse command line arguments
SKIP_EMULATOR=false
CHECK_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -c|--coverage)
            COVERAGE=true
            shift
            ;;
        -f|--file)
            TEST_FILE="$2"
            shift 2
            ;;
        -n|--name)
            TEST_NAME="$2"
            shift 2
            ;;
        -s|--skip-emulator)
            SKIP_EMULATOR=true
            shift
            ;;
        --check)
            CHECK_ONLY=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║   FridgeFinder Test Runner           ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""

    # Check prerequisites
    check_prerequisites

    if [ "$CHECK_ONLY" = true ]; then
        exit 0
    fi

    echo ""

    # Start emulator if needed
    if [ "$SKIP_EMULATOR" = false ]; then
        start_emulator
        echo ""
    fi

    # Run tests
    if run_tests; then
        EXIT_CODE=0
    else
        EXIT_CODE=1
    fi

    echo ""

    # Stop emulator if we started it
    if [ "$SKIP_EMULATOR" = false ] && [ "$EMULATOR_RUNNING" = true ]; then
        stop_emulator
    fi

    echo ""
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║   All tests passed! 🎉                ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}╔═══════════════════════════════════════╗${NC}"
        echo -e "${RED}║   Some tests failed 😞                ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════╝${NC}"
    fi
    echo ""

    exit $EXIT_CODE
}

# Trap to ensure emulator is stopped on exit
trap 'stop_emulator' EXIT INT TERM

# Run main function
main
