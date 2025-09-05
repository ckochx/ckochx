#!/bin/bash
set -e

# Ckochx Release Build Script
# Builds a production release with hot upgrade support

VERSION=${1:-$(grep -o 'version: "[^"]*"' mix.exs | cut -d'"' -f2)}
RELEASE_DIR="_build/prod/rel/ckochx"

echo "🚀 Building Ckochx release v${VERSION}"
echo "=================================="

# Clean previous builds
echo "📦 Cleaning previous builds..."
mix clean
rm -rf _build/prod

# Set production environment
export MIX_ENV=prod

# Get dependencies and compile
echo "📥 Installing dependencies..."
mix deps.get --only prod

echo "🔨 Compiling application..."
mix deps.compile
mix compile

# Build the release
echo "🎯 Building release..."
mix release --overwrite

echo "📋 Release built successfully!"
echo "   Version: ${VERSION}"
echo "   Location: ${RELEASE_DIR}"
echo "   Size: $(du -sh ${RELEASE_DIR} | cut -f1)"

# Create tarball for deployment
TARBALL_NAME="ckochx-${VERSION}.tar.gz"
echo "📦 Creating deployment tarball: ${TARBALL_NAME}"

cd _build/prod/rel/ckochx
tar -czf "../../../../${TARBALL_NAME}" .
cd - > /dev/null

echo "✅ Release build complete!"
echo "   Tarball: ${TARBALL_NAME}"
echo ""
echo "Next steps:"
echo "  1. Copy ${TARBALL_NAME} to your production server"
echo "  2. Extract and run: ./bin/ckochx start"
echo "  3. For hot upgrades, place new releases in /opt/ckochx/releases/"