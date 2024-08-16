#!/bin/bash

# Loop through all files that match the pattern "get_coverage_*.sh"
for script in get_coverage_*.sh; do
  # Check if the file is executable
  if [ -x "$script" ]; then
    echo "Executing $script"
    ./"$script"
  else
    echo "Skipping $script (not executable)"
  fi
done

echo "All scripts executed."
