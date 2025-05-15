function generate_path() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

        local workspace_dir=$(git rev-parse --show-toplevel)
        local workspace_name="%F{31}${workspace_dir:t}%f%F{37}⇢$branch_name%f"

        local workspace_status=$(git status --porcelain 2>/dev/null)

        if [[ -n $workspace_status ]]; then
            workspace_status=" %F{178}⊙%f"
        else
            workspace_status=""
        fi

        if [[ $PWD == $workspace_dir ]]; then
            path="%F{241}:/%f"
        else
            path="%F{241}:${PWD#$workspace_dir}%f"
        fi

        echo "$workspace_name$path$workspace_status"
    else
        echo "%F{241}%~%f"
    fi
}

# Alias
alias clear-dns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias remember-key='ssh-add --apple-use-keychain'
alias restart-tunnel='sudo launchctl stop com.cloudflare.cloudflared && sudo launchctl start com.cloudflare.cloudflared'

# Prompt
setopt PROMPT_SUBST
export PROMPT='$(generate_path) %F{235}❱%f '

# PATH
export PATH="$PATH:/opt/homebrew/Cellar/mysql-client@8.4/8.4.4/bin"
export PATH="$HOME/Development/Environment:$HOME/Development/Environment/bin:$HOME/Development/Environment/android-sdk/platform-tools:$HOME/Development/Environment/flutter/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/Users/bas/.local/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/bas/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# SSH Autocomplete
zstyle ':completion:*:(ssh|scp|ftp|sftp):*' hosts $hosts
autoload -U compinit && compinit

# Bun completions
[ -s "/Users/bas/.bun/_bun" ] && source "/Users/bas/.bun/_bun"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Utilities
bun-all() {
    if [ $# -eq 0 ]; then
        >&2 echo "⛔ Please provide a Bun sub-command."
        return 1
    fi

    command="$1"
    shift 1

    for d in $(find . -name "package.json" -not -path "*/node_modules/*" -not -path "*/\.*/*" -exec dirname {} \;); do
        eval "bun $command --cwd $d $@"
    done
}
