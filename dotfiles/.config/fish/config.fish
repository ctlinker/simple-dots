# Commands to run in interactive sessions can go here
if status is-interactive
    # Starship prompt
    starship init fish | source
    # Aliases
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
end

# SSH Agent
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c)
    set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
    set -Ux SSH_AGENT_PID $SSH_AGENT_PID
end

# Custom fish greeting
function fish_greeting
    echo "[Welcome to Fish! $(whoami)] Type 'help' to see the Fish shell documentation"
    echo ""
    fastfetch
end

# Environment variables
set -gx PROTO_HOME "$HOME/.proto"
set -gx PATH "$PROTO_HOME/shims" "$PROTO_HOME/bin" $PATH $HOME/go/bin

# Hardware Accel
set -gx LIBVA_DRIVER_NAME iHD
set -gx VDPAU_DRIVER va_gl

# Cargo env
eval "sh $HOME/.cargo/env"

# XDG Directories
cat "$HOME/.config/user-dirs.dirs" | sed -E '/^#/d; s/^(XDG_[^=]+)="?([^"]+)"?/set -gx \1 \2/' | source
set -gx PATH $PATH ~/bin


# Added by Antigravity CLI installer
set -gx PATH "/home/chlinks/.local/bin" $PATH
