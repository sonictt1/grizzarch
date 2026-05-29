#!/bin/bash

# Wayland display protocol and X11 compatibility layer for legacy apps
pacman -S --noconfirm wayland xorg-xwayland

# Sway window manager, compositor, and Wayland utilities
pacman -S --noconfirm sway swaylock swayidle swaybg

# Terminal emulator — Wayland-native replacement for termite
pacman -S --noconfirm foot

# Application launcher — Wayland-native replacement for dmenu
pacman -S --noconfirm wofi

# Status bar data provider (works with swaybar, same format as i3bar)
pacman -S --noconfirm i3status

# Audio — PipeWire with PulseAudio compatibility (pactl still works)
pacman -S --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber alsa-utils

# Fonts
pacman -S --noconfirm ttf-droid

# Desktop portal and privilege escalation for Wayland sessions
pacman -S --noconfirm xdg-utils xdg-desktop-portal-wlr polkit

# Core utilities
pacman -S --noconfirm git vim

# Build tools (required for AUR helper and manual compilation)
pacman -S --noconfirm --needed base-devel