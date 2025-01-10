export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
if [ "$TERM" = "fbterm" ]; then
        source /usr/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
else
	if [ "$(id -u)" -eq 0 ]; then
	        PS1='\u@\H:\w# '
	else
	        PS1='\u@\H:\w$ '
	fi
fi

