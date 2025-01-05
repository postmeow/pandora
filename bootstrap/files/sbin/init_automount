#!/bin/bash
echo "Looking for persistent storage..."
for dev in $(ls /sys/class/block/); do
        mkdir -p /mnt/$dev
        mount /dev/$dev /mnt/$dev 2> /dev/null
        if [ $? -eq 0 ]; then
                if [ -f /mnt/$dev/pandora/.pandora-loader ]; then
                        echo Found pandora storage on $dev
                        for mountdir in $(ls /mnt/$dev/pandora/etc 2> /dev/null); do
                                mount --bind /mnt/$dev/pandora/etc/$mountdir /etc/$mountdir
                                echo Mounted /mnt/$dev/pandora/etc/$mountdir
                        done
                        for mountdir in $(ls /mnt/$dev/pandora/home 2> /dev/null); do
				mkdir -p /home/$mountdir
                                mount --bind /mnt/$dev/pandora/home/$mountdir /home/$mountdir
                                echo Mounted /mnt/$dev/pandora/home/$mountdir
                        done
                        if [ -f /mnt/$dev/pandora/swap ]; then
                                swapon /mnt/$dev/pandora/swap
                        fi
                        if [ -f /mnt/$dev/pandora/init ]; then
                                /mnt/$dev/pandora/init 2> /dev/null &
                        fi
                fi
        fi
done
