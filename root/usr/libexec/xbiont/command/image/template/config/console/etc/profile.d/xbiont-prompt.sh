## Colored prompt
if [ -n "$PS1" ]; then
    if [ $(id -u) -eq 0 ]; then
        # Root: Username Red, Title: u@h:W
        PS1='\[\e]0;\u@\h:\W\a\]\[\e[91m\]\u\[\e[90m\]@\h \[\e[0m\]\W\$ '
    else
        # User: Username Blue, Title: u@h:W
        PS1='\[\e]0;\u@\h:\W\a\]\[\e[94m\]\u\[\e[90m\]@\h \[\e[0m\]\W\$ '
    fi
fi
