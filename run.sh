#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# List of scripts to run in order
SCRIPTS=(
  "babacoin.sh"
  "bitoreum.sh"
  "fewbit.sh"
  "raptoreum.sh"
  "yerbas.sh"
)

# === RUN SCRIPTS INTERACTIVELY ===
for script in "${SCRIPTS[@]}"; do
  if [ -f "$script" ]; then
    echo
    echo "-----------------------------------------"
    echo "Ready to install: $script"
    echo "-----------------------------------------"
    read -p "Do you want to run $script? (y/n): " answer
    case "$answer" in
      [Yy]* )
        chmod +x "$script"
        echo "Running $script..."
        bash "$script"
        echo "$script completed successfully."
        ;;
      [Nn]* )
        echo "Skipped $script."
        ;;
      * )
        echo "Invalid input, skipping $script."
        ;;
    esac
  else
    echo "⚠️  Warning: $script not found, skipping."
  fi
done

echo
echo "✅ All done!"
