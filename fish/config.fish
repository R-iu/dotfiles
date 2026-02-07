#set -g fish_greeting

if status is-interactive
    starship init fish | source
    zoxide init fish | source
    fzf --fish | source
    thefuck --alias fk | source
    direnv hook fish | source
end

if test "$TERM" = xterm-ghostty
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

alias cd="z"
alias py="python"
alias cat="bat"

fzf_configure_bindings --processes=\cp

# use fd instead of fzf
# set fzf_preview_file_cmd bat -n
set fzf_fd_opts --hidden --strip-cwd-prefix --exclude .git
set fzf_diff_highlighter delta --side-by-side --paging=never --width=125
set fzf_history_time_format %d-%m-%y

export BAT_THEME=tokyonight_night
export GIT_PAGER=delta

alias g="lazygit"
alias d="lazydocker"

alias rtraj="source ~/Documents/robocon/Optimal-Trajectory/.venv/bin/activate.fish && trajplanner"
# alias unzip="7z e"

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

