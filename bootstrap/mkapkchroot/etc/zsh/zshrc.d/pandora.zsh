export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
hostname $(cat /etc/hostname)
hostname=$(hostname)
if [ "$TERM" = "fbterm" ]; then
        source /usr/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
else
	PROMPT="%n@$hostname:%~"
	if [ "$(id -u)" -eq 0 ]; then
		PROMPT=$PROMPT"# "
	else
		PROMPT=$PROMPT"$ "
	fi
fi

