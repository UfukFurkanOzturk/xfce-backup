#!/bin/bash
# usage of this script
# for backup use "sh xfce-backup.sh backup"
# for restore from backup use "sh xfce-backup-restore.sh restore"
# while using restore, xfce4-backup.tar.gz have to be in the same directory with this script
MODE=$1 # mode

# main backup function
function backupmain() {
    #current themes
    eval THEME="$(gsettings get org.gnome.desktop.interface gtk-theme)"
    eval ICON="$(gsettings get org.gnome.desktop.interface icon-theme)"
    eval CURSOR="$(gsettings get org.gnome.desktop.interface cursor-theme)"
    eval CURSORSIZE="$(xfconf-query -c xsettings -p /Gtk/CursorThemeSize)"
    cp -r "/$HOME/.config/xfce4/" .
    mkdir Theme && cp -r "/usr/share/themes/$THEME" ./Theme
    mkdir Icons && cp -r "/usr/share/icons/$ICON" ./Icons
    mkdir Cursor && cp -r "/usr/share/icons/$CURSOR" ./Cursor
    cp "/$HOME/.face" .
    echo "$THEME" >> ./Theme/currenttheme
    echo "$ICON" >> ./Icons/currenticon
    echo "$CURSOR" >> ./Cursor/currentcursor && echo "$CURSORSIZE" >> ./Cursor/currentsize
    tar -czf ./xfce4-backup.tar.gz xfce4 Theme Icons Cursor .face 
    cp ./xfce4-backup.tar.gz "./out/"
    rm -r xfce4 Theme Icons Cursor .face xfce4-backup.tar.gz
}

function backup() {
  if [[ $(id -u) != 0 ]]; then
    if [ -f "./out/xfce4-backup.tar.gz" ]; then
        backupmain
        echo "backup file successfully overwritten!"
    else
        backupmain
        echo "backup file successfully created!"
    fi
  else
    echo "don't run this as root"
  fi
}

function restore() {
    tar -xf ./xfce4-backup.tar.gz
    THEME=$(cat ./Theme/currenttheme)
    ICON=$(cat ./Icons/currenticon)
    CURSOR=$(cat ./Cursor/currentcursor)
    CURSORSIZE=$(cat ./Cursor/currentsize)
    cp -r xfce4 "$HOME/.config/"
    cp .face "/$HOME/"
    sudo cp -r "./Theme/$THEME" "/usr/share/themes/"
    sudo cp -r "./Icons/$ICON" "/usr/share/icons/"
    sudo cp -r "./Cursor/$CURSOR" "/usr/share/icons/"
    xfconf-query -c xsettings -p /Net/ThemeName -s "$THEME"
    xfconf-query -c xsettings -p /Net/IconThemeName -s "$ICON"
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$CURSOR"
    xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s "$CURSORSIZE"
    rm -r xfce4 Theme Icons Cursor .face
    echo "xfce config and theme restored"
}

# check mode
if [[ $(id -u) != 0 ]]; then
  if [ "$MODE" = backup ]; then
    if [ -d "/$HOME/.config/xfce4/" ]; then
        # create an output file if it isn't exists
        if [ -d "./out/" ]; then
            :
        else
            mkdir out
        fi
        backup
    else
        echo "couldn't find the config"
    fi
elif [ "$MODE" = restore ]; then
    if [ -f "./xfce4-backup.tar.gz" ]; then
        restore
    else
        echo "couldn't find the config"
    fi
else
    echo "error '$MODE' is not an argument use 'backup' or 'restore'"
fi
  else
  echo "don't run this as root"
fi
