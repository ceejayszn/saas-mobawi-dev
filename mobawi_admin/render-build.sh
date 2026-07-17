#!/bin/bash
# render-build.sh
# Custom build script for Render to install Flutter and build the web app

echo "Cloning Flutter stable channel..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

echo "Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Getting packages..."
flutter pub get

echo "Building Flutter Web with CanvasKit..."
# Using canvaskit avoids WASM header issues that cause blank screens
flutter build web --release --web-renderer canvaskit

echo "Build complete."
