#!/bin/bash
# vercel-build.sh
# Custom build script for Vercel to install Flutter and build the web app

echo "Cloning Flutter stable channel..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

echo "Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Getting packages..."
flutter pub get

echo "Building Flutter Web..."
flutter build web --release --base-href "/"

echo "Copying vercel.json to build output..."
cp vercel.json build/web/

echo "Build complete."
