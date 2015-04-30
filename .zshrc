autoload -U compinit promptinit colors 
compinit
promptinit
colors
setopt prompt_subst 

zmodload zsh/complist zsh/terminfo

#-----------------------------------
# shell variables
#-----------------------------------
export EDITOR=vim

#-----------------------------------
# colors are nice
#-----------------------------------

# make some aliases for the colours: (coud use normal escap.seq's too)
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
eval PR_$color='%{$fg[${(L)color}]%}'
done
PR_NO_COLOR="%{$terminfo[sgr0]%}"

# https://github.com/seebi/dircolors-solarized
# Also a repo in the AUR
eval `dircolors /etc/dir_colors `


#-----------------------------------
# version control in prompt
#-----------------------------------
autoload -Uz vcs_info

# I really only use these version control systems
zstyle ':vcs_info:*' enable git svn

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '!'
zstyle ':vcs_info:*' unstagedstr '?' 
zstyle ':vcs_info:*' formats "${PR_CYAN}(%s)-[%b] %m%u%c% ${PR_NO_COLOR}"
precmd() {
    vcs_info
}
 
#-----------------------------------
# Prompt found in https://github.com/MrElendig/dotfiles-alice/blob/master/.zshrc
#-----------------------------------
setprompt () {

    # Check the UID
    if [[ $UID -ge 1000 ]]; then # normal user
    eval PR_USER='${PR_GREEN}%n${PR_NO_COLOR}'
    eval PR_USER_OP='${PR_GREEN}%#${PR_NO_COLOR}'
    elif [[ $UID -eq 0 ]]; then # root
    eval PR_USER='${PR_RED}%n${PR_NO_COLOR}'
    eval PR_USER_OP='${PR_RED}%#${PR_NO_COLOR}'
    fi  

    # Check if we are on SSH or not
    if [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
    eval PR_HOST='${PR_YELLOW}%M${PR_NO_COLOR}' #SSH
    else
    eval PR_HOST='${PR_GREEN}%M${PR_NO_COLOR}' # no SSH
    fi
    # set the prompt
    RPROMPT=$'${vcs_info_msg_0_}'
    PS1=$'${PR_CYAN}┌[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}]\n└[${PR_MAGENTA}%~${PR_CYAN}]${PR_USER_OP} '
    PS2=$'%_>'
}
setprompt

#-----------------------------------
# History settings
#-----------------------------------
#Save lots and use a single file
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.history
# append all history into the shared file ignoreing space and duplicates
setopt append_history share_history histignorealldups histignorespace
# history search
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
# ctrl+j and ctrl+k search forward and back through history with the contents of
# the current line up till the cursor
bindkey '^K' history-beginning-search-backward
bindkey '^J' history-beginning-search-forward

# Enable home and end keys
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

#-----------------------------------
# Autocompletion stuff
#-----------------------------------
zstyle ':completion:*' menu select

setopt glob_complete completealiases correct_all autocd

#-----------------------------------
# Keybindings
#-----------------------------------
if [[ "$TERM" != emacs ]] ; then
    [[ -z "$terminfo[kdch1]" ]] || bindkey -M emacs "$terminfo[kdch1]" delete-char
    [[ -z "$terminfo[khome]" ]] || bindkey -M emacs "$terminfo[khome]" beginning-of-line
    [[ -z "$terminfo[kend]"  ]] || bindkey -M emacs "$terminfo[kend]"  end-of-line
    [[ -z "$terminfo[kdch1]" ]] || bindkey -M vicmd "$terminfo[kdch1]" vi-delete-char
    [[ -z "$terminfo[khome]" ]] || bindkey -M vicmd "$terminfo[khome]" vi-beginning-of-line
    [[ -z "$terminfo[kend]"  ]] || bindkey -M vicmd "$terminfo[kend]"  vi-end-of-line
    [[ -z "$terminfo[cuu1]"  ]] || bindkey -M viins "$terminfo[cuu1]"  vi-up-line-or-history
    [[ -z "$terminfo[cuf1]"  ]] || bindkey -M viins "$terminfo[cuf1]"  vi-forward-char
    [[ -z "$terminfo[kcuu1]" ]] || bindkey -M viins "$terminfo[kcuu1]" vi-up-line-or-history
    [[ -z "$terminfo[kcud1]" ]] || bindkey -M viins "$terminfo[kcud1]" vi-down-line-or-history
    [[ -z "$terminfo[kcuf1]" ]] || bindkey -M viins "$terminfo[kcuf1]" vi-forward-char
    [[ -z "$terminfo[kcub1]" ]] || bindkey -M viins "$terminfo[kcub1]" vi-backward-char
    # ncurses stuff:
    [[ "$terminfo[kcuu1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcuu1]/O/[}" vi-up-line-or-history
    [[ "$terminfo[kcud1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcud1]/O/[}" vi-down-line-or-history
    [[ "$terminfo[kcuf1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcuf1]/O/[}" vi-forward-char
    [[ "$terminfo[kcub1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcub1]/O/[}" vi-backward-char
    [[ "$terminfo[khome]" == $'\eO'* ]] && bindkey -M viins "${terminfo[khome]/O/[}" beginning-of-line
    [[ "$terminfo[kend]"  == $'\eO'* ]] && bindkey -M viins "${terminfo[kend]/O/[}"  end-of-line
    [[ "$terminfo[khome]" == $'\eO'* ]] && bindkey -M emacs "${terminfo[khome]/O/[}" beginning-of-line
    [[ "$terminfo[kend]"  == $'\eO'* ]] && bindkey -M emacs "${terminfo[kend]/O/[}"  end-of-line
fi


## use the vi navigation keys (hjkl) besides cursor keys in menu completion
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom

# Enable backwards tab using shift-tab
bindkey -M menuselect '^[[Z' reverse-menu-complete

#use emacs style key navigation
bindkey -e

#-----------------------------------
#alias's
#-----------------------------------
# Global
alias ls='ls --color=auto'
alias pacman='pacman --color=auto'

# extention based
alias -s c=vim

#.git has been moved to .homegit
alias hgit='git --git-dir=$HOME/.homegit --work-tree=$HOME'

#Stop sudo from being corrected
alias sudo='nocorrect sudo'
