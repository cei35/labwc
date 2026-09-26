#!/bin/sh

# -----------------------------------------
#           Designed for Alpine
#
#   - Need to be run as root
#   - Need existing user passed as $1
# -----------------------------------------


if [ "$(id -u)" -ne 0 ]; then
    echo "Error: this script must be run as root." >&2
    exit 1
fi

if ! id -u "$1" >/dev/null 2>&1; then
    echo "Error: user '$1' does not exist." >&2
    exit 1
fi

USER_HOME="/home/$1"

# apk  add
# ----------------------------------------------
# mesa libraries for 3D graphics
# Labwc, its doc and the foot terminal
# Waybar, its doc and fuzzel the app launcher
# Seatd the minimal seat manager daemon, dbus and dconf
# Sway's programs for background, standby mode and lockscreen
# Notification daemon and its lib
# PAM module used to set Labwc's running directory and util to find current user
# Audio and brightness management
# JetBrains font, Adwaita theme and Papirus icons
# Ristretto image viewer and mousepad notes, both from xfce
# Few applications, kate replace codium.
# Thunar and udisks/gvfs for mounting usb drives
# Greetd minimal login manager with its TUI theme
# All stuff to screen, save and copy.
# Needed Libreoffice packages

apk add mesa-dri-gallium mesa-va-gallium \
    labwc labwc-doc foot \
    waybar waybar-doc fuzzel \
    seatd dbus dconf \
    swaybg swayidle swaylock \
    mako libnotify \
    pam-rundir util-linux-login \
    pipewire pipewire-pulse wireplumber pamixer brightnessctl \
    font-jetbrains-mono-nerd font-noto-emoji font-dejavu hicolor-icon-theme papirus-icon-theme adwaita-icon-theme \
    ristretto mousepad \
    keepassxc librewolf kate \
    thunar udisks2 gvfs \
    greetd greetd-tuigreet \
    grim slurp wl-clipboard \
    libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-lang-fr libreoffice-gtk3

cp etc/doas.d/* /etc/doas.d/
chmod 0400 /etc/doas.d

mkdir -p /etc/greetd/
cp etc/greetd/config.toml /etc/greetd/config.toml
chown root:root /etc/greetd/config.toml
chmod 600 /etc/greetd/config.toml

setup-devd udev
rc-update add seatd default
rc-update add greetd default

addgroup desktop
addgroup bob seat       # 'seat' group replaces the need for 'input' and 'video' groups which are unnecessary 
                        # and insecure (cf. https://gitlab.alpinelinux.org/alpine/aports/-/work_items/15409).
addgroup bob audio
addgroup bob desktop    # Used to allow Polkit permissions for udisks and NM.

mkdir -p $USER_HOME/.config/
cp -r foot/ fuzzel/ gtk-3.0/ labwc/ mako/ swaylock/ waybar/ lock.png background.png $USER_HOME/.config/
cp .bashrc .profile $USER_HOME/

chmod +x $USER_HOME/.config/waybar/weather.sh
chmod +x $USER_HOME/.config/labwc/toggle-dock.sh

# dconf part
mkdir -p /etc/dconf/profile /etc/dconf/db/local.d

cat << 'EOF' > /etc/dconf/profile/user
user-db:user
system-db:local
EOF

cat << 'EOF' > /etc/dconf/db/local.d/00-theme
[org/gnome/desktop/interface]
icon-theme='Papirus-Dark'
gtk-theme='Adwaita'
EOF

dconf update
# ---------------------------------------------


chown -R "$1":"$1" $USER_HOME