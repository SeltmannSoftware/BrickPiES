#!/bin/bash

operation=$1
shift
for var in "$@"
do
case "$var" in
  led)
    case "$operation" in
      disable)
        echo "Disabling power LED...editing /boot/config.txt"
        if 
          grep -q '#enable_uart=1' /boot/config.txt; 
        then 
          echo 'Power LED support already disabled!'; 
        else 
          if 
            grep -q 'enable_uart=1' /boot/config.txt; 
          then 
            sed -n -i 's/enable_uart=1/#enable_uart=1/' /boot/config.txt
          else 
            echo "Disable failed...power LED support not installed"
          fi
        fi
        ;;
      enable)
        echo "Enabling power LED...editing /boot/config.txt. Reboot required."
        if 
          grep -q '#enable_uart=1' /boot/config.txt; 
        then 
          sed -n -i 's/#enable_uart=1/enable_uart=1/' /boot/config.txt
        else 
          if 
            grep -q 'enable_uart=1' /boot/config.txt; 
          then 
            echo 'Power LED support already installed!'; 
          else 
            echo '\n# Power LED (via TxD)\nenable_uart=1\n' >> /boot/config.txt;
          fi
        fi
        ;;
      *)
        echo "Usage: brickpies disable|enable led|power|reset"
        exit 1
    esac
    ;;
  power)
    case "$operation" in
      disable)
        echo "Disabling gpio power button...editing /boot/config.txt"
        if 
          grep -q '#dtoverlay=gpio-shutdown' /boot/config.txt; 
        then 
          echo 'GPIO power support already disabled!'; 
        else 
          if 
            grep -q 'dtoverlay=gpio-shutdown' /boot/config.txt; 
          then 
            sed -n -i 's/dtoverlay=gpio-shutdown/#dtoverlay=gpio-shutdown/' /boot/config.txt
          else 
            echo "Disable failed...GPIO power support not enabled"
          fi
        fi
        ;;
      enable)
        echo "Enabling POWER button...editing /boot/config.txt. Reboot required."
        if 
          grep -q '#dtoverlay=gpio-shutdown' /boot/config.txt; 
        then 
          sed -n -i 's/#dtoverlay=gpio-shutdown/dtoverlay=gpio-shutdown/' /boot/config.txt
        else 
          if 
            grep -q 'dtoverlay=gpio-shutdown' /boot/config.txt; 
          then 
            echo 'Power LED support already installed!'; 
          else 
            printf '\n# Power off (via gpio 3)\ndtoverlay=gpio-shutdown\n' >> /boot/config.txt;
          fi
        fi
        ;;
      *)
        echo "Usage: brickpies disable|enable led|power|reset"
        exit 1
    esac
    ;;
  reset)
    case "$operation" in
      disable)
        echo "Disabling reset..."
        #Disable - add sudo?
        update-rc.d gpio_soft_reset disable
        /etc/init.d/gpio_soft_reset stop
        ;;
      enable)
        echo "Enabling reset..."

        # Enable
        # Install if needed
        if [ ! -e /etc/init.d/gpio_soft_reset ]
        then
          cp gpio_soft_reset /etc/init.d
          chmod +x /etc/init.d/gpio_soft_reset
        fi
        if [ ! -e /usr/local/bin/soft_reset_listener.py ] 
        then
          cp soft_reset_listener.py /usr/local/bin
          chmod +x /usr/local/bin/soft_reset_listener.py
        fi

        # Now enable - add sudo?
        update-rc.d gpio_soft_reset defaults
        /etc/init.d/gpio_soft_reset start
        ;;

      remove)

        #Remove
        echo "Removing reset..."
        update-rc.d gpio_soft_reset disable
        /etc/init.d/gpio_soft_reset stop
        if [ -e /etc/init.d/gpio_soft_reset ]
        then
          rm /etc/init.d/gpio_soft_reset
        fi
        if [ -e /usr/local/bin/soft_reset_listener.py ]
        then 
          rm /usr/local/bin/soft_reset_listener.py
        fi
        ;;

      *)
        echo "Usage: brickpies disable|enable led|power|reset"
        exit 1
    esac
    ;;
  *)
    echo "Usage: brickpies disable|enable led|power|reset"
    exit 1
esac
done
