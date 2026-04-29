stow:
	stow -t ~/ -v --stow "dotfiles" 

unstow:
	stow -t ~/ -v --delete "dotfiles"

restow:
	stow -t ~/ -v --restow "dotfiles"

update: unstow stow
	hyprctl reload
