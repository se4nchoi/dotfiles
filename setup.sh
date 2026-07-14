#!/bin/bash

# Define paths
DOTFILES_DIR="$HOME/dotfiles"
PRIVATE_CONFIG="$HOME/.gitconfig-private"
TARGET_CONFIG="$HOME/.gitconfig"
BACKUP_CONFIG="$HOME/.gitconfig.bak"

echo "⚙️  Starting Git dotfiles installation..."

# 1. Handle the private identity file
if [ ! -f "$PRIVATE_CONFIG" ]; then
    echo "📝 Private config file not found at $PRIVATE_CONFIG"
    echo "Let's set up your local identity (this stays private on your machine):"
    
    read -p "Enter your full name: " user_name
    read -p "Enter your email address: " user_email

    cat << EOF > "$PRIVATE_CONFIG"
[user]
        name = $user_name
        email = $user_email
EOF
    echo "✅ Created private configuration file."
else
    echo "ℹ️  Found existing private config file at $PRIVATE_CONFIG. Skipping creation."
fi

# 2. Backup existing global .gitconfig if it's a real file (not a symlink)
if [ -f "$TARGET_CONFIG" ] && [ ! -L "$TARGET_CONFIG" ]; then
    echo "⚠️  Found an existing local .gitconfig file. Backing it up to $BACKUP_CONFIG"
    mv "$TARGET_CONFIG" "$BACKUP_CONFIG"
fi

# 3. Create the symbolic link
if [ -L "$TARGET_CONFIG" ]; then
    echo "ℹ️  Symlink already exists. Overwriting to ensure it points to the correct location."
    rm "$TARGET_CONFIG"
fi

ln -s "$DOTFILES_DIR/.gitconfig" "$TARGET_CONFIG"
echo "✅ Linked $DOTFILES_DIR/.gitconfig to $TARGET_CONFIG"

echo "🎉 Git environment setup complete! You are ready to go."

