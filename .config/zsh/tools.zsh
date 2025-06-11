#!/usr/bin/env zsh

VERBOSE=0

# IMPORTANT: We MUST use MODIFIED_PATH (see notes in ~/.zshrc).
# Otherwise tools like curl, sh etc can't be found otherwise.
export PATH="$MODIFIED_PATH"

typeset -a tools=(
  # shell command replacements
  zoxide            # cd replacement
  bat               # cat replacement
  eza               # ls replacement
  fd                # find replacement
  "ripgrep:rg"      # grep replacement
  sd                # sed replacement
  "git-delta:delta" # git pager replacement

  # tools
  starship           # prompt
  jless              # json viewer
  mise               # dev tools etc
  fzf                # fuzzy finder
  "difftastic:difft" # syntax-aware git diff (ignoring indentation changes, etc)
  yadm               # dotfiles management
  zinit              # zsh plugin manager
)

typeset -a fonts=(
  "font-geist-mono-nerd-font:*GeistMono*Nerd*"
)

check_zinit() {
  local zinit_paths=(
    "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/zinit"
  )

  for zinit_path in "${zinit_paths[@]}"; do
    if [[ -d "$zinit_path" ]]; then
      return 0
    fi
  done

  # Also check if zinit command is available (in case it's sourced)
  if typeset -f zinit >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

check_tool_installed() {
  local formula="$1"
  local executable="$2"

  case "$formula" in
  zinit)
    check_zinit
    ;;
  *)
    command -v "$executable" >/dev/null 2>&1
    ;;
  esac
}

# collect missing tools
typeset -a missing_formulas=()

for tool_spec in "${tools[@]}"; do
  if [[ "$tool_spec" == *":"* ]]; then
    formula="${tool_spec%:*}"
    executable="${tool_spec#*:}"
  else
    formula="$tool_spec"
    executable="$tool_spec"
  fi

  if ! check_tool_installed "$formula" "$executable"; then
    echo "$executable not found."
    missing_formulas+=("$formula")
  elif ((VERBOSE)); then
    echo "$executable is already installed."
  fi
done

# collect missing fonts
typeset -a missing_fonts=()

for font_spec in "${fonts[@]}"; do
  if [[ "$font_spec" == *":"* ]]; then
    formula="${font_spec%:*}"
    pattern="${font_spec#*:}"
  else
    formula="$font_spec"
    pattern="*${font_spec#font-}*"
  fi

  if ! find /System/Library/Fonts /Library/Fonts ~/Library/Fonts -name "$pattern" 2>/dev/null | head -1 | read; then
    echo "$formula not found."
    missing_fonts+=("$formula")
  elif ((VERBOSE)); then
    echo "$formula is already installed."
  fi
done

# install missing tools and fonts
if ((${#missing_formulas[@]} > 0)); then
  echo "Installing missing tools: ${missing_formulas[*]}"
  brew install "${missing_formulas[@]}"
elif ((VERBOSE)); then
  echo "All tools are already installed."
fi

if ((${#missing_fonts[@]} > 0)); then
  echo "Installing missing fonts: ${missing_fonts[*]}"
  brew install --cask "${missing_fonts[@]}"
elif ((VERBOSE)); then
  echo "All fonts are already installed."
fi
