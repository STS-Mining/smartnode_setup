#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status


COIN_NAME="raptoreum"
COIN_PORT="10226"
RPC_PORT="8484"
COIN_TAR="raptoreum-ubuntu20-2.0.3.01-mainnet-.tar.gz"
COIN_URL="https://github.com/Raptor3um/raptoreum/releases/download/2.0.3.01-mainnet/${COIN_TAR}"
BOOTSTRAP_URL="https://bootstrap.raptoreum.com/bootstraps/bootstrap.zip"
POWCACHE_URL="https://bootstrap.raptoreum.com/bootstraps/powcache.dat"

# Ensure required packages are installed
sudo apt update && sudo apt install -y wget unzip nano
sudo ufw allow $COIN_PORT/tcp
sudo ufw allow $RPC_PORT/tcp

# Create base directories
COIN_DIR="$HOME/$COIN_NAME"
WORK_DIR="$HOME/.${COIN_NAME}core"

mkdir -p "$COIN_DIR" "$WORK_DIR"

echo "🚀 Installing $COIN_NAME ..."
cd "$COIN_DIR"

# Download and extract binary
echo "⬇️  Downloading binary..."
wget -q --show-progress "$COIN_URL"

# Extract the TAR.GZ if it exists
if [ -f "$COIN_TAR" ]; then
    tar -xf "$COIN_TAR"
    rm "$COIN_TAR"
fi

# Detect the newly created subfolder (if any)
SUBDIR=$(find . -mindepth 1 -maxdepth 1 -type d ! -name ".*" | head -n 1)

# If a subfolder exists, move its contents up and delete it
if [ -n "$SUBDIR" ]; then
    echo "📂 Moving files from subfolder '$SUBDIR' to $COIN_DIR ..."
    mv "$SUBDIR"/* "$COIN_DIR"/ 2>/dev/null || true
    rm -rf "$SUBDIR"
fi

# Create configuration file
echo "⚙️  Creating configuration file..."
cat <<EOF > "$WORK_DIR/$COIN_NAME.conf"
#rpcuser=
#rpcpassword=
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
server=1
daemon=1
listen=1
#smartnodeblsprivkey=
port=$COIN_PORT
EOF

# Download bootstrap and powcache
cd "$WORK_DIR"
echo "⬇️  Downloading bootstrap and powcache..."
wget -q --show-progress "$POWCACHE_URL"
wget -q --show-progress "$BOOTSTRAP_URL"

unzip -o bootstrap.zip
rm bootstrap.zip

# Move contents of bootstrap folder if needed
if [ -d "bootstrap" ]; then
    mv bootstrap/* .
    rmdir bootstrap
fi

echo "✅ Installation complete."

# Prompt user to review configuration
read -p "Would you like to review the config file now? (y/n): " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    nano "$WORK_DIR/$COIN_NAME.conf"
fi

chmod +x "$COIN_DIR"/*d || true

read -p "Start the daemon now? (y/n): " start_ans
if [[ "$start_ans" =~ ^[Yy]$ ]]; then
    "$COIN_DIR/${COIN_NAME}d" -daemon
    echo "✅ $COIN_NAME daemon started."
fi

