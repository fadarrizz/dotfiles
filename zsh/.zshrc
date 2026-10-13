# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# Completions
autoload -Uz compinit && compinit

# Custom aliases/functions
source "$DOTFILES/zsh/custom/aliases.zsh"
source "$DOTFILES/zsh/custom/functions.zsh"

# Plugins (managed through Homebrew)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # must be last among plugins

if command -v gh >/dev/null 2>&1; then
  GITHUB_API_TOKEN="$(gh auth token 2>/dev/null)" &&
    export GITHUB_API_TOKEN &&
    export HOMEBREW_GITHUB_API_TOKEN="$GITHUB_API_TOKEN"
fi

# Tools

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Like cd but better
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Python virtualenv
if [ -d "$HOME/myenv" ]; then
  source "$HOME/myenv/bin/activate"
fi

# Ruby env
eval "$(rbenv init - --no-rehash zsh)"

# Set keymap Sessionizer
bindkey -s ^f "t\n"

# Mise
eval "$(mise activate zsh)"

# Fzf
eval "$(fzf --zsh)"

# dp-devinfra
#eval "$(dp-devinfra destinations access --export-env-vars "$1" "$2" "$3")"

# Prompt (must be last)
eval "$(starship init zsh)"
