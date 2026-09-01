#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Auto-start Sway on TTY1
if [[ -z $WAYLAND_DISPLAY && $(tty) = /dev/tty1 ]]; then
    # Required for VirtualBox Wayland/wlroots compatibility
    export WLR_NO_HARDWARE_CURSORS=1
    export WLR_RENDERER=pixman
    exec sway
fi
