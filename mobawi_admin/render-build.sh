#!/usr/bin/env bash
# exit on error
set -o errexit

npm install
npm run build

# Render is looking for build/web (from the previous Flutter setup)
# so we move our React 'dist' folder contents into 'build/web'
mkdir -p build/web
cp -r dist/* build/web/

