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
  jless              # json viewer
  mise               # dev tools etc
  fzf                # fuzzy finder
  "difftastic:difft" # syntax-aware git diff (ignoring indentation changes, etc)
  yadm               # dotfiles management
)

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

  if ! command -v "$executable" >/dev/null 2>&1; then
    echo "$executable not found."
    missing_formulas+=("$formula")
  elif ((VERBOSE)); then
    echo "$executable is already installed."
  fi
done

# install missing tools (at once - should be faster)
if ((${#missing_formulas[@]} > 0)); then
  echo "Installing missing tools: ${missing_formulas[*]}"
  brew install "${missing_formulas[@]}"
elif ((VERBOSE)); then
  echo "All tools are already installed."
fi
