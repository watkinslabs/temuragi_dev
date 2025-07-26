#!/bin/sh
# Setup development certificates using mkcert

# Check if mkcert is installed
if ! command -v mkcert >/dev/null 2>&1; then
    echo "mkcert not found. Installing..."
    
    if [ "$(uname)" = "Darwin" ]; then
        # macOS
        if command -v brew >/dev/null 2>&1; then
            brew install mkcert
        else
            echo "Error: Homebrew not found. Install mkcert manually."
            exit 1
        fi
    elif [ -f /etc/fedora-release ] || [ -f /etc/centos-release ]; then
        # Fedora/CentOS
        sudo dnf install -y mkcert
    else
        echo "Error: Unsupported OS. Install mkcert manually."
        exit 1
    fi
fi

# Install the local CA (only needed once per system)
echo "Installing local CA..."
mkcert -install

# Create certs directory
mkdir -p certs

# Generate certificates
echo "Generating certificates for temuragi.local..."
cd certs
mkcert -cert-file temuragi.local.crt -key-file temuragi.local.key \
    temuragi.local "*.temuragi.local" localhost 127.0.0.1 ::1

cd ..

echo ""
echo "✓ Certificates generated in ./certs/"
echo "✓ Local CA installed in system trust store"
echo ""
echo "Files created:"
echo "  - certs/temuragi.local.crt (certificate)"
echo "  - certs/temuragi.local.key (private key)"
echo ""
echo "Important: Restart Chrome completely for changes to take effect"