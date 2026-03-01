# Bash-specific initialization, including for non-login and remote
# shells (info "(bash) Bash Startup Files").

# Provide a default prompt.
# PS1='\u@\h \w${GUIX_ENVIRONMENT:+ [env]}\$ '

# Export 'SHELL' to child processes.  Programs such as 'screen'
# honor it and otherwise use /bin/sh.
export SHELL

if [[ $- != *i* ]]; then
    # We are being invoked from a non-interactive shell.  If this
    # is an SSH session (as in "ssh host command"), source
    # /etc/profile so we get PATH and other essential variables.
    [[ -n "$SSH_CLIENT" ]] && source /etc/profile

    # Don't do anything else, returning a successful return code.
    return 0
fi

for i in "$HOME"/bashrc.d/*.sh; do
    [[ -r $i ]] && source "$i"
done
unset i

# Increase the history size (default is 500 entries).
HISTSIZE=10000

alias clear='printf "\e[2J\e[H"'

# get current branch in git repo
function parse_git_branch() {
    BRANCH=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ ! "${BRANCH}" == "" ]; then
        STAT=$(parse_git_dirty)
        echo "[${BRANCH}${STAT}]"
    else
        echo ""
    fi
}

# get current status of git repo
function parse_git_dirty {
    status=$(git status 2>&1 | tee)
    dirty=$(
        echo -n "${status}" 2>/dev/null | grep "modified:" &>/dev/null
        echo "$?"
    )
    untracked=$(
        echo -n "${status}" 2>/dev/null | grep "Untracked files" &>/dev/null
        echo "$?"
    )
    ahead=$(
        echo -n "${status}" 2>/dev/null | grep "Your branch is ahead of" &>/dev/null
        echo "$?"
    )
    newfile=$(
        echo -n "${status}" 2>/dev/null | grep "new file:" &>/dev/null
        echo "$?"
    )
    renamed=$(
        echo -n "${status}" 2>/dev/null | grep "renamed:" &>/dev/null
        echo "$?"
    )
    deleted=$(
        echo -n "${status}" 2>/dev/null | grep "deleted:" &>/dev/null
        echo "$?"
    )
    bits=''
    if [ "${renamed}" == "0" ]; then
        bits=">${bits}"
    fi
    if [ "${ahead}" == "0" ]; then
        bits="*${bits}"
    fi
    if [ "${newfile}" == "0" ]; then
        bits="+${bits}"
    fi
    if [ "${untracked}" == "0" ]; then
        bits="?${bits}"
    fi
    if [ "${deleted}" == "0" ]; then
        bits="x${bits}"
    fi
    if [ "${dirty}" == "0" ]; then
        bits="!${bits}"
    fi
    if [ ! "${bits}" == "" ]; then
        echo " ${bits}"
    else
        echo ""
    fi
}

function is_toolbox() {
    if [ "${HOSTNAME}" == "toolbox" ]; then
        TOOLBOX_NAME=$(cat /run/.containerenv | grep -oP "(?<=name=\")[^\";]+")
        echo "[${HOSTNAME} ${TOOLBOX_NAME}]"
    fi
}

export PS1="\[\e[31m\]\`is_toolbox\`\]\e[m\]\[\e[36m\]\`parse_git_branch\`\[\e[m\]\[\e[32m\]\\$ \[\e[m\]\[\e[37m\]❱\[\e[m\] "
