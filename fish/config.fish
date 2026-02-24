if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting ""
set -p PATH ~/.local/bin
starship init fish | source
zoxide init fish --cmd cd | source
fzf --fish | source
thefuck --alias fk | source
direnv hook fish | source

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

abbr lsfg 'set LSFG_PROCESS "miyu"'
# fa运行fastfetch
abbr fa fastfetch
abbr reboot 'systemctl reboot'

function shutdown
    sysup
end

if test "$TERM" = xterm-kitty
    fastfetch
end

# List Directory
alias l='eza -lh  --icons=auto' # long list
alias ls='eza -1   --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree

# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -p'

alias cat="bat"

fzf_configure_bindings --processes=\cp

# use fd instead of fzf
# set fzf_preview_file_cmd bat -n
set fzf_fd_opts --hidden --strip-cwd-prefix --exclude .git
set fzf_diff_highlighter delta --side-by-side --paging=never --width=125
set fzf_history_time_format %d-%m-%y

export BAT_THEME="Catppuccin Mocha"
export GIT_PAGER=delta

alias g="lazygit"
alias d="lazydocker"

# git lazy config
alias gpr="git pull --recurse-submodules"
alias gcr="git clone --recurse-submodules"

# uv lazy config
function uvi --wraps uv --description 'alias uvi= uv init'
    uv init $argv
    cd $argv[1] | echo "source .venv/bin/activate" >.envrc
    uv venv
    direnv allow .
end
