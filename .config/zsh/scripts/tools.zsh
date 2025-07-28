#!/usr/bin/env zsh

# IMPORTANT: We MUST use MODIFIED_PATH (see notes in ~/.zshrc).
# Otherwise tools like curl, sh etc can't be found otherwise.
export PATH="$MODIFIED_PATH"

VERBOSE=0

if [[ "$OSTYPE" == "darwin"* ]]; then
  FONT_DIRS=("/System/Library/Fonts" "/Library/Fonts" "$HOME/Library/Fonts")
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  FONT_DIRS=("/usr/share/fonts" "$HOME/.fonts" "$HOME/.local/share/fonts")
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

# only run every hour, or if this script has been modified
last_run_file="${XDG_CACHE_HOME:-$HOME/.cache}/tool_check_last_run"
tools_script="${(%):-%x}"

if [[ -f "$last_run_file" ]] && [[ "$last_run_file"(mh-1) ]] && [[ ! "$tools_script" -nt "$last_run_file" ]]; then
  return
fi

echo "\033[90m[tools.zsh]\033[0m running tool check"

if ! command -v brew >/dev/null 2>&1; then
  echo "\033[91m[tools.zsh]\033[0m brew not found. Install Homebrew first: https://brew.sh"
  return 1
fi

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
  antidote           # zsh plugin manager
  gron               # make json greppable (e.g. gron [json] | rg key.key2)
  curlie             # nicer curl
  hyperfine          # benchmarker
  hexyl              # cli hex viewer
  atuin              # better terminal history
  csvlens            # csv viewer
  vivid              # LS_COLORS generator
  pastel             # color manipulation tool
)

typeset -a fonts=(
  "font-geist-mono-nerd-font:*GeistMono*Nerd*"
)

check_sourced_tool() {
  local tool_name="$1"
  local check_type="$2"  # 'file' or 'dir'
  local path="$3"
  
  # check if the file/directory exists
  if [[ "$check_type" == "file" && -f "$path" ]] || [[ "$check_type" == "dir" && -d "$path" ]]; then
    return 0
  fi
  
  # check if the function is available (in case it's sourced)
  if typeset -f "$tool_name" >/dev/null 2>&1; then
    return 0
  fi
  
  return 1
}

check_tool_installed() {
  local formula="$1"
  local executable="$2"

  case "$formula" in
  # zinit)
  #   check_sourced_tool "zinit" "dir" "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/zinit"
  #   ;;
  antidote)
    check_sourced_tool "antidote" "file" "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
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

  found=0
  for dir in "${FONT_DIRS[@]}"; do
    if find "$dir" -iname "$pattern" 2>/dev/null | grep -q .; then
      found=1
      break
    fi
  done

  if (( !found )); then
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
  echo ""
elif ((VERBOSE)); then
  echo "All tools are already installed."
fi

if ((${#missing_fonts[@]} > 0)); then
  echo "Installing missing fonts: ${missing_fonts[*]}"
  brew install --cask "${missing_fonts[@]}"
  echo ""
elif ((VERBOSE)); then
  echo "All fonts are already installed."
fi

touch "$last_run_file"

echo ""
