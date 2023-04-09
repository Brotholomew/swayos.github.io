#!/bin/bash
#
# This script installs SwayOS on a pre-installed arch linux
# A user with sudo permissions and a live network connection is needed
#

REPO_DIR=$PWD

# Set up logging
exec 1> >(tee "swayos_setup_out")
exec 2> >(tee "swayos_setup_err")

log(){
    echo "*********** $1 ***********"
    now=$(date +"%T")
    echo "$now $1" >> ~/swayos_setup_log
}

check(){
    if [ "$1" != 0 ]; then
	echo "$2 error : $1" | tee -a ~/swayos_setup_log
	exit 1
    fi
}

log "Refreshing package db"
sudo pacman -Syu
check "$?" "pacman"

log "Installing needed official packages"
sudo pacman -S --noconfirm --needed \
     sudo \
     zsh \
     zsh-autosuggestions \
     iwd \
     bluez \
     bluez-utils \
     blueman \
     pipewire \
     pipewire-alsa \
     pipewire-pulse \
     pipewire-jack \
     wireplumber \
     pamixer \
     xdg-desktop-portal-wlr \
     xorg-xwayland \
     wayland-protocols \
     sway \
     swaybg \
     swayidle \
     swaylock \
     grim \
     slurp \
     waybar \
     wofi \
     brightnessctl \
     kitty \
     nautilus \
     gnome-system-monitor \
     system-config-printer \
     cups \
     polkit-gnome \
     wl-clipboard \
     pavucontrol \
     adapta-gtk-theme

log "Installing aur dependencies"

sudo pacman -S --noconfirm --needed \
     base-devel \
     git \
     scdoc \
     gtk4 \
     itstool \
     vala \
     asciidoc \
     gobject-introspection \
     python-importlib-metadata \
     python-mako \
     python-markdown \
     python-markupsafe \
     python-zipp \
     ttf-liberation \
     archlinux-appstream-data \
     appstream-glib \
     qrencode \
     libxss \
     perl-error \
     perl-mailtools \
     perl-timedate \
     vte-common \
     vte3 \
     dbus-glib \
     wayland \
     freetype2 \
     ffmpeg \
     libpng \
     libgl \
     libegl \
     glew \
     openjpeg2 \
     libmupdf \
     gumbo-parser \
     mujs \
     curl \
     wget


log "install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cd ~/.oh-my-zsh/themes
git clone https://github.com/eendroroy/alien.git
cd $REPO_DIR


log "Copying settings to home folder"
cp -f -R home/. ~/
check "$?" "cp"


items=(yay-git ly ttf-iosevka terminus-font-ttf sov mmfm vmp wcp wob wlogout wdisplays iwgtk libpamac-aur pamac-aur google-chrome vscodium)

log "Installing aur packages"
for i in "${items[@]}"
do
    log "Installing $line"
    pkg=$i
    git clone https://aur.archlinux.org/$pkg.git
    cd $pkg
    makepkg -si --skippgpcheck --noconfirm
    check "$?" "makepkg"
    sudo pacman -U --noconfirm *.pkg.tar.zst
    check "$?" "pacman -U"
    cd ..
done


log "Starting services"
sudo systemctl enable iwd --now
sudo systemctl enable bluetooth --now
sudo systemctl enable cups --now
sudo systemctl enable ly


log "Linking software store"
sudo ln /usr/bin/pamac-manager /usr/bin/appstore


log "Changing shell to zsh"
chsh -s /bin/zsh
check "$?" "chsh"


log "Setup is done, please log out and log in back again ( type exit )"
