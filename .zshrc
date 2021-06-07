
# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

setopt histignorealldups sharehistory

# Set up the prompt

autoload -Uz promptinit && promptinit
autoload -Uz colors && colors
autoload -Uz vcs_info
#prompt adam1

setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{green}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats " %c%u%b"
zstyle ':vcs_info:*' actionformats ' %c%u%b[%a]'


# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history


function check_commits() {
  PROMPT_COMMITS_MARK=""

  git rev-parse --show-toplevel --quiet >/dev/null 2>&1
  if [[ $? -eq 0 ]]
  then
    BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null)"
    if [[ "$BRANCH" != "" ]]
    then
      UP="⇡"
      DOWN="⇣"
      RIGHT="⇢"
      UNPUSHED_MARK="$(git log --oneline "origin/$BRANCH..$BRANCH" 2>/dev/null | wc -l | awk '$1>0{print "'"$UP"'"}')"
      UNPULLED_MARK="$(git log --oneline "$BRANCH..origin/$BRANCH" 2>/dev/null | wc -l | awk '$1>0{print "'"$DOWN"'"}')"
      if [[ "$UNPUSHED_MARK" = "" ]]
      then
        UNPUSHED_MARK="$(git branch -r 2>/dev/null | grep "$BRANCH" | wc -l | awk '$1==0{print "'"$RIGHT"'"}')"
      fi
      PROMPT_COMMITS_MARK="$UNPUSHED_MARK$UNPULLED_MARK"
    fi
  fi
}

function precmd() {
#	print ""
}

function precmd_prompt() {
  vcs_info
  check_commits
  PROMPT_EXEC_TIME_NOW="$(date +%s%3N)"
  PROMPT_EXEC_TIME="$(echo "scale=1; ($PROMPT_EXEC_TIME_NOW - ${PROMPT_EXEC_TIME_START:-"$PROMPT_EXEC_TIME_NOW"}) / 1000" | bc)s"
}
function preexec_prompt() {
  PROMPT_EXEC_TIME_START="$(date +%s%3N)"
}
add-zsh-hook precmd precmd_prompt
add-zsh-hook preexec preexec_prompt


#PROMPT=$PROMPT'${vcs_info_msg_0_}'
PROMPT='%F{blue}%~%f%F{008}${vcs_info_msg_0_}%F{cyan}$PROMPT_COMMITS_MARK%f%(?..%F{red} (%?%))%f %F{008}$PROMPT_EXEC_TIME%f %F{yellow}%*%f%(?.%F{magenta}.%F{red})$ %f'


# Use modern completion system
autoload -Uz compinit
compinit


zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'



# 自己設定

# GitHub CLI補完
eval "$(gh completion -s zsh)"
# zsh補完機能
#autoload -U compinit
#compinit


# コマンドプロンプトの表示変更
# 
#export PS1="%1~ %# "
#export PROMPT=$PS1

# clipboard alias
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -selection c -o'

# キーマップ設定
xmodmap ~/.Xmodmap 

# オーディオ対策
# これをしないと音声が出てこない
# https://wiki.archlinux.org/index.php/HP_Spectre_x360_(2020)#Audio
#sudo hda-verb /dev/snd/hwC0D0 0x01 SET_GPIO_DIR 0x01
#sudo hda-verb /dev/snd/hwC0D0 0x01 SET_GPIO_MASK 0x01
#sudo hda-verb /dev/snd/hwC0D0 0x01 SET_GPIO_DATA 0x01
#sudo hda-verb /dev/snd/hwC0D0 0x01 SET_GPIO_DATA 0x00

# PATH追加
PATH=$PATH:/home/jun/Settings/adr-tools-3.0.0/src
PATH=$PATH:/usr/local/bin/dart-sdk/bin/
PATH=$PATH:$HOME/.pub-cache/bin


# dotnet cli補完
# zsh parameter completion for the dotnet CLI
_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  reply=( "${(ps:\n:)completions}" )
}

compctl -K _dotnet_zsh_complete dotnet

# Bashからのお引越し
#
#
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
# shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
#unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'

alias gi='git'
alias g='git'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi
