BREW := /usr/local/bin/brew

.PHONY: all 
all: dotfiles

.PHONY: dotfiles 
dotfiles: bash vim tmux ## Install bash vim tmux configs

.PHONY: macosx
macosx: brew golang-mac pyenv

.PHONY: bash 
bash: ## Install the bash related dotfiles.
	@echo "Starting bash Setup..."
	ln -sfn $(CURDIR)/bash/bashrc $(HOME)/.bashrc
	ln -sfn $(CURDIR)/bash/bash_profile $(HOME)/.bash_profile
	ln -sfn $(CURDIR)/bash/git-completion.bash $(HOME)/.git-completion.bash
	@echo "Done! (bash)\n"

.PHONY: vim 
vim: ## Install vimrc & Vundle.vim and its packages.
	@echo "Starting vim Setup..."
	ln -sfn $(CURDIR)/vim/vimrc $(HOME)/.vimrc
	git clone https://github.com/VundleVim/Vundle.vim.git $(HOME)/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall
	@echo "Done! (vim)\n"

.PHONY: tmux 
tmux: ## Install tmux related dotfiles.
	@echo "Starting tmux Setup..."
	mkdir -p $(HOME)/.tmux;
	ln -sfn $(CURDIR)/tmux/tmux-cpu $(HOME)/.tmux/tmux-cpu
	ln -sfn $(CURDIR)/tmux/tmux.conf $(HOME)/.tmux.conf
	ln -sfn $(CURDIR)/tmux/tmux.conf.local $(HOME)/.tmux.conf.local
	@echo "Done! (tmux)"

.PHONY: git
git: ## Install git configs.
	@cp $(CURDIR)/git/gitconfig $(HOME)/.gitconfig
	@read -p "Enter your name: " git_name; \
		sed "/{{GIT_NAME}}/s/$$/ $$git_name/" $(HOME)/.gitconfig
	@read -p "Enter your e-mail: " git_email; \
		sed "/{{GIT_EMAIL}}/s/$$/ $$git_email/" $(HOME)/.gitconfig
.PHONY: pyenv
pyenv: ## Install pyenv.
	@echo "Starting pyenv Setup..."
	$(if $(shell pyenv versions), \
		@echo "pyenv is installed already", \
		git clone https://github.com/pyenv/pyenv.git $(HOME)/.pyenv, \
		git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv)
	@echo "Done! (pyenv)"

.PHONY: golang
ifeq (${OS},OSX)
golang: | brew ## Install golang.
	@echo "Starting go Setup..."
	brew install go
	@echo "Done! (go)"
else
golang:
	@echo "Starting go Setup..."
	@echo "Done! (go)"
endif

.PHONY: brew
brew: | $(BREW) ## Install brew if it isn't installed, then update brew 
	brew update

$(BREW): ## Install brew if it's not installed already
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

.PHONY: clean-vim
clean-vim:
	@echo "Cleaning vim setting up..."
	@echo "Detecting existing vimrc"
	vim +PlugClean +qall
	rm -r $(HOME)/.vim
	@echo "Done! (cleaning vim)"

.PHONY: clean-bash
clean-bash:
	@echo "Cleaning bash setting up..."
	@echo "Detecting existing bashrc and bash_profile"
	rm $(HOME)/.bashrc; \
	rm $(HOME)/.bash_profile; \
	@echo "Done! (cleaning bash)"

.PHONY: clean-dotfiles 
clean-dotfiles: clean-bash clean-vim ## Clean the dotfiles.
	rm $(HOME)/.tmux.conf.local
	rm -r $(HOME)/.tmux $(HOME)/.vim
	@echo "Done! (cleaning)"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
