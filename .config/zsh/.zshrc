function add_path() {
    export PATH=$PATH:$1
}

add_path ${HOME}/.nodebrew/current/bin
add_path ${HOME}/.rbenv/shims
add_path ${HOME}/.nimble/bin
add_path ${HOME}/opt/anaconda3/bin
add_path ${HOME}/opt/anaconda3/condabin
add_path ${HOME}/.anyenv/envs/nodenv/shims
add_path ${HOME}/.anyenv/envs/nodenv/bin
add_path /Library/Frameworks/Python.framework/Versions/3.10/bin
add_path /usr/local/bin
add_path /usr/bin
add_path /bin
add_path /usr/sbin
add_path /sbin
add_path /Library/TeX/texbin
add_path /usr/local/share/dotnet
add_path ${HOME}/.dotnet/tools
add_path /Library/Apple/usr/bin
add_path /Library/Frameworks/Mono.framework/Versions/Current/Commands
add_path ${HOME}/.cargo/bin
add_path /opt/homebrew/bin
add_path /opt/homebrew/opt/fzf/bin

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('${HOME}/mambaforge/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/mambaforge/etc/profile.d/conda.sh" ]; then
        . "${HOME}/mambaforge/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/mambaforge/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "${HOME}/mambaforge/etc/profile.d/mamba.sh" ]; then
    . "${HOME}/mambaforge/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

export GEM_HOME="$HOME/.gem"
eval "$(starship init zsh)"
