#!/usr/bin/env zsh

# IMPORTANT: We MUST use MODIFIED_PATH (see notes in ~/.zshrc).
# Otherwise tools like curl, sh etc can't be found otherwise.
export PATH="$MODIFIED_PATH"

extract() {
  if [[ ! -f "$1" ]]; then
    echo "Error: '$1' not found" >&2
    return 1
  fi

  local file="$(realpath "$1")" # Get absolute path
  local basename="${file:t}"

  # Get folder name by removing all extensions
  local folder_name="$basename"
  folder_name="${folder_name%.tar.*}"
  folder_name="${folder_name%.t[gbx]z*}"
  folder_name="${folder_name%.*}"

  echo "Extracting $basename to $folder_name/..."

  # Handle existing folder (case-insensitive check)
  local existing_folder=""
  if [[ -d "$folder_name" ]]; then
    existing_folder="$folder_name"
  else
    # Check for case-insensitive match
    for dir in *(/); do # zsh glob for directories only
      if [[ "${dir:l}" == "${folder_name:l}" ]]; then
        existing_folder="$dir"
        break
      fi
    done
  fi

  if [[ -n "$existing_folder" ]]; then
    echo "Folder '$existing_folder' already exists. Extract into it? (y/N)"
    read -q "REPLY?"
    echo
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
      echo "Extraction cancelled."
      return 1
    fi
    folder_name="$existing_folder" # Use the existing folder's actual name
  else
    mkdir -p "$folder_name"
  fi

  cd "$folder_name"

  case "${basename:l}" in
  *.tar.bz2 | *.tbz2) tar -xjf "$file" ;;
  *.tar.gz | *.tgz) tar -xzf "$file" ;;
  *.tar.xz | *.txz) tar -xJf "$file" ;;
  *.tar.zst) tar --use-compress-program=zstd -xf "$file" ;;
  *.tar.lz4) tar --use-compress-program=lz4 -xf "$file" ;;
  *.tar) tar -xf "$file" ;;
  *.bz2) bunzip2 -k "$file" ;;
  *.gz) gunzip -k "$file" ;;
  *.xz) unxz -k "$file" ;;
  *.zst | *.zstd) zstd -dk "$file" ;;
  *.lz4) lz4 -dk "$file" ;;
  *.zip) unzip -q "$file" ;;
  *.rar) unrar x "$file" ;;
  *.7z) 7z x "$file" ;;
  *.z) gunzip -k "$file" ;;
  *)
    echo "Unknown format, trying 7z..."
    7z x "$file"
    ;;
  esac

  local exit_code=$?
  cd ..

  if [[ $exit_code -eq 0 ]]; then
    echo "Extracted to: $PWD/$folder_name/"
  else
    echo "Failed to extract $basename" >&2
    rmdir "$folder_name" 2>/dev/null # Clean up empty folder
    return 1
  fi
}
