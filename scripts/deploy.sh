#!/bin/bash
set -e

# Ckochx Deployment Script
# Deploys releases with hot upgrade support

USAGE="Usage: $0 <server> <version> [action]
  server:  Target server (e.g., user@hostname)
  version: Release version to deploy
  action:  deploy|upgrade|rollback (default: upgrade)"

SERVER=$1
VERSION=$2
ACTION=${3:-upgrade}

if [[ -z "$SERVER" || -z "$VERSION" ]]; then
    echo "$USAGE"
    exit 1
fi

RELEASE_DIR="/opt/ckochx"
TARBALL="ckochx-${VERSION}.tar.gz"
REMOTE_SCRIPT="/tmp/ckochx_deploy_${VERSION}.sh"

echo "🚀 Deploying Ckochx v${VERSION} to ${SERVER}"
echo "============================================="

# Check if tarball exists locally
if [[ ! -f "$TARBALL" ]]; then
    echo "❌ Release tarball not found: $TARBALL"
    echo "   Run ./scripts/build_release.sh first"
    exit 1
fi

case $ACTION in
    "deploy")
        echo "📤 Initial deployment to ${SERVER}..."
        
        # Create remote deployment script
        cat > /tmp/deploy_script.sh << 'EOF'
#!/bin/bash
set -e

RELEASE_DIR="/opt/ckochx"
VERSION="$1"
TARBALL="ckochx-${VERSION}.tar.gz"

echo "🏗️  Setting up Ckochx deployment directory..."
sudo mkdir -p ${RELEASE_DIR}/{releases,bin}
sudo chown -R $(whoami):$(whoami) ${RELEASE_DIR}

echo "📦 Extracting release..."
cd ${RELEASE_DIR}
tar -xzf /tmp/${TARBALL}

echo "🔧 Setting up systemd service..."
sudo tee /etc/systemd/system/ckochx.service > /dev/null << 'SERVICE'
[Unit]
Description=Ckochx Web Server
After=network.target

[Service]
Type=exec
User=ckochx
Group=ckochx
WorkingDirectory=/opt/ckochx
Environment=PORT=4000
Environment=MIX_ENV=prod
ExecStart=/opt/ckochx/bin/ckochx start
ExecStop=/opt/ckochx/bin/ckochx stop
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

# Create ckochx user if it doesn't exist
if ! id -u ckochx > /dev/null 2>&1; then
    sudo useradd --system --home /opt/ckochx --shell /bin/bash ckochx
fi

sudo chown -R ckochx:ckochx ${RELEASE_DIR}
sudo systemctl daemon-reload
sudo systemctl enable ckochx
sudo systemctl start ckochx

echo "✅ Deployment complete!"
echo "   Service status: $(sudo systemctl is-active ckochx)"
echo "   Logs: journalctl -u ckochx -f"
EOF

        # Copy files and execute
        scp "$TARBALL" "$SERVER:/tmp/"
        scp /tmp/deploy_script.sh "$SERVER:/tmp/"
        ssh "$SERVER" "chmod +x /tmp/deploy_script.sh && /tmp/deploy_script.sh $VERSION"
        ;;
        
    "upgrade")
        echo "🔄 Hot upgrading to v${VERSION}..."
        
        # Copy new release
        scp "$TARBALL" "$SERVER:/tmp/"
        
        # Create upgrade script
        cat > /tmp/upgrade_script.sh << 'EOF'
#!/bin/bash
set -e

VERSION="$1"
TARBALL="ckochx-${VERSION}.tar.gz"
RELEASE_DIR="/opt/ckochx/releases/${VERSION}"

echo "📦 Preparing upgrade to v${VERSION}..."
mkdir -p "${RELEASE_DIR}"
cd "${RELEASE_DIR}"
tar -xzf "/tmp/${TARBALL}"

echo "🔄 Triggering hot upgrade..."
/opt/ckochx/bin/ckochx rpc "Ckochx.UpgradeManager.upgrade_to_version('${VERSION}')"

echo "✅ Hot upgrade initiated!"
echo "   Check logs: journalctl -u ckochx -f"
EOF

        scp /tmp/upgrade_script.sh "$SERVER:/tmp/"
        ssh "$SERVER" "chmod +x /tmp/upgrade_script.sh && /tmp/upgrade_script.sh $VERSION"
        ;;
        
    "rollback")
        echo "⏪ Rolling back on ${SERVER}..."
        ssh "$SERVER" "/opt/ckochx/bin/ckochx rpc 'Ckochx.UpgradeManager.rollback()'"
        echo "✅ Rollback initiated!"
        ;;
        
    *)
        echo "❌ Unknown action: $ACTION"
        echo "$USAGE"
        exit 1
        ;;
esac

echo ""
echo "🎯 Deployment actions complete!"
echo "   Monitor logs: ssh $SERVER 'journalctl -u ckochx -f'"