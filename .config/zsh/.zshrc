# ────────────────────────────── options ──────────────────────────────

PROFILE=0

# ────────────────────────────── scripts ──────────────────────────────

# IMPORTANT: $PATH in sourced scripts is the path to the script itself.
# So we assign the parent .zshrc PATH to MODIFIED_PATH and use that in sourced scripts.
# We do this by re-assigning PATH in the sourced script to MODIFIED_PATH.
# Then at the end of the sourced script we re-export the updated MODIFIED_PATH.
# Later on you'll see us prefix this .zshrc PATH with MODIFIED_PATH.
export MODIFIED_PATH="$PATH"

function load_script {
	local path=$1
	if test -f $path; then
		source $path
	else
		echo "ERROR: script $path not found"
	fi
}

load_script "$XDG_CONFIG_HOME/zsh/bindings-Integralist.zsh"
load_script "$XDG_CONFIG_HOME/zsh/tools.zsh"
load_script "$XDG_CONFIG_HOME/zsh/functions.zsh"

export PATH="$MODIFIED_PATH:$PATH"
typeset -U path # dedupe

# ────────────────────────────── init ──────────────────────────────

(( PROFILE )) && zmodload zsh/zprof

# source global shell alias & variables files
[ -f "$XDG_CONFIG_HOME/shell/alias" ] && source "$XDG_CONFIG_HOME/shell/alias"
# [ -f "$XDG_CONFIG_HOME/shell/vars" ] && source "$XDG_CONFIG_HOME/shell/vars"

source /opt/homebrew/opt/zinit/zinit.zsh # zinit

# ────────────────────────────── modules ──────────────────────────────

autoload -U compinit && compinit
autoload -U colors && colors

# ────────────────────────────── cmp opts ──────────────────────────────

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# ────────────────────────────── history opts ──────────────────────────────

HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$XDG_CACHE_HOME/zsh_history" # move histfile to cache
HISTCONTROL=ignoreboth # consecutive duplicates & commands starting with space are not saved

setopt append_history inc_append_history share_history # better history
# on exit, history appends rather than overwrites; history is appended as soon as cmds executed; history shared across sessions

# ────────────────────────────── general opts ──────────────────────────────

setopt auto_menu menu_complete # show menu on first tab hit after partial completion
setopt autocd # type a dir to cd (nice zoxide fallback)
setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space
setopt no_case_glob no_case_match # make cmp case insensitive
setopt globdots # include dotfiles
setopt extended_glob # match ~ # ^
setopt interactive_comments # allow comments in shell
unsetopt prompt_sp # don't autoclean blanklines

# https://stackoverflow.com/a/42679697
unsetopt nomatch

bindkey '\e[H' beginning-of-line # fn + left to start of line
bindkey '\e[F' end-of-line # fn + right to end of line

WORDCHARS="" # use native word separation behaviour

# ────────────────────────────── header ──────────────────────────────

COLOUR_BG_DARK="#121211"
COLOUR_FG_LIGHT="#d5c4a1"
COLOUR_BG_LIGHT="#21201e"
COLOUR_FG_DARK="#ab9d82"
COLOUR_FG_DIM="#8c816b"

show_uptime_header() {
	local uptime_output shell_path
	
	# Get shell path once
	shell_path=${SHELL:-$0}
	
	# Parse uptime in a single read, avoiding multiple subprocess calls
	uptime_output=$(uptime | sed -E 's/.*up ([^,]*), [0-9]+ user.*/\1/' | awk '{
		output = ""
		
		# Check for days
		for (i=1; i<=NF; i++) {
			if ($i ~ /^[0-9]+$/ && $(i+1) ~ /^day/) {
				output = $i " days"
				break
			}
		}
		
		# Check for time format (hours:minutes)
		for (i=1; i<=NF; i++) {
			if ($i ~ /^[0-9]+:[0-9]+$/) {
				split($i, time_arr, ":")
				hours = time_arr[1]
				minutes = time_arr[2]
				
				if (output) output = output ", "
				if (hours > 0) output = output hours " hours"
				if (minutes > 0) {
					if (hours > 0) output = output ", "
					output = output minutes " minutes"  
				}
				found_time = 1
				break
			}
		}
		
		# Check for minutes only (if no time format found)
		if (!found_time) {
			for (i=1; i<=NF; i++) {
				if ($i ~ /^[0-9]+$/ && $(i+1) ~ /^min/) {
					if (output) output = output ", "
					output = output $i " minutes"
					break
				}
			}
		}
		
		print output
	}')
	
	# Single print statement
	print -P "%K{$COLOUR_BG_DARK}%F{$COLOUR_FG_DIM} ${shell_path} %K{$COLOUR_BG_LIGHT}%F{$COLOUR_FG_DARK} up ${uptime_output} %k%f"
}

# Show header on shell start
show_uptime_header

# ────────────────────────────── plugins ──────────────────────────────

plugins=(
	zsh-users/zsh-completions
	zdharma-continuum/fast-syntax-highlighting
	zsh-users/zsh-autosuggestions
	Aloxaf/fzf-tab
	blimmer/zsh-aws-vault
	zsh-users/zsh-history-substring-search
)

for plugin in "${plugins[@]}"; do
	zinit ice wait lucid # loads asynchronously (wait = same as wait"0", lucid = no "Loaded x" message)
	zinit light "$plugin"
done

# ────────────────────────────── tool activation ──────────────────────────────

activations=(
	"fzf --zsh"
	"mise activate zsh"
	"zoxide init zsh"
)

# asynchronously run each activation script using zinit
for activation in "${activations[@]}"; do
	zinit ice wait lucid atload"eval \"\$($activation)\""
	zinit light zdharma-continuum/null
done

eval "$(starship init zsh)"

(( PROFILE )) && zprof
