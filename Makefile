.PHONY: all 
all: dotfiles

ifeq ($(OS),Windows_NT)
	UNAME = Windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S), Linux)
		UNAME = Linux
	endif
	UNAME ?= Other
endif

install:
	@make $(UNAME)

Linux: bash fzf fish git mutt byobu weechat vim nvim gnupg bin vscode sublime
Windows: bash git vim
Other: bash git vim


.PHONY: dotfiles 
dotfiles: bash vim tmux ## Installs bash vim tmux configs

.PHONY: macosx
macosx: brew golang-mac pyenv

.PHONY: bash 
bash: ## Installs the bash related dotfiles.
	@echo "Starting bash Setup..."
	ln -sfn $(CURDIR)/bash/bashrc $(HOME)/.bashrc
	ln -sfn $(CURDIR)/bash/bash_profile $(HOME)/.bash_profile
	ln -sfn $(CURDIR)/bash/git-completion.bash $(HOME)/.git-completion.bash
	@echo "Leaving breadcrums..."
	echo "v0.0.1" > $(CURDIR)/tmp/bash/breadcrums
	@echo "Done! (breadcrums-bash)\n"
	@echo "Done! (bash)\n"

.PHONY: vim 
vim: ## Installs vimrc & Vundle.vim and its packages.
	@echo "Starting vim Setup..."
	ln -sfn $(CURDIR)/.vimrc $(HOME)/.vimrc
	git clone https://github.com/VundleVim/Vundle.vim.git $(HOME)/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall
	@echo "Leaving breadcrums..."
	echo "v0.0.1" > $(CURDIR)/tmp/vim/breadcrums
	@echo "Done! (breadcrums-vim)\n"
	@echo "Done! (vim)\n"

.PHONY: tmux 
tmux: ## Installs tmux related dotfiles.
	@echo "Starting tmux Setup..."
	mkdir -p $(HOME)/.tmux;
	ln -sfn $(CURDIR)/.tmux/tmux-cpu $(HOME)/.tmux/tmux-cpu
	ln -sfn $(CURDIR)/.tmux/.tmux.conf $(HOME)/.tmux.conf
	ln -sfn $(CURDIR)/.tmux/.tmux.conf.local $(HOME)/.tmux.conf.local
	@echo "Done! (tmux)"

.PHONY: pyenv
pyenv: ## Installs pyenv.
	@echo "Starting pyenv Setup..."
	$(if $(shell pyenv versions), \
		@echo "pyenv is installed already", \
		git clone https://github.com/pyenv/pyenv.git $(HOME)/.pyenv)
	@echo "Done! (pyenv)"

.PHONY: golang
ifeq (${OS},OSX)
golang: brew-check ## Installs golang from brew.
	@echo "Starting go Setup..."
	brew install go
	@echo "Done! (go)"
else
golang:
	@echo "Starting go Setup..."
	@echo "Done! (go)"
endif

.PHONY: brew-check
brew-check: ## Check if brew is installed. Abort if it isn't.
	@echo "Checking if brew is installed..."
	$(if $(shell which brew), \
		@echo "Yayy! brew is installed." \
		,$(error "Brew is not installed"))
	@echo "Done! (brew-check)"

.PHONY: clean-dotfiles 
clean-dotfiles: ## Clean the dotfiles.
	@echo "Cleaning up..."
	@echo "Detecting existing bashrc and bash_profile"
	@if [ -f "$(HOME)/.bashrc" ] ; then \
		echo "bashrc detected!! moved to tmp/bash directory"; \
		mkdir -p $(CURDIR)/tmp/bash; \
		cp $(HOME)/.bashrc $(CURDIR)/tmp/bash/.bashrc && rm $(HOME)/.bashrc; \
		rm $(CURDIR)/tmp/bash/breadcrums; \
	fi
	@if [ -f "$(HOME)/.bash_profile" ] ; then \
		echo "bash_profile detected!! moved to tmp/bash directory"; \
		mkdir -p $(CURDIR)/tmp/bash; \
		cp $(HOME)/.bash_profile $(CURDIR)/tmp/bash/.bash_profile && rm $(HOME)/.bash_profile; \
	fi 
	@echo "Detecting existing vimrc"
	@if [ -f "$(HOME)/.vimrc" ] ; then \
		echo "vimrc detected!! moved to tmp/vim directory"; \
		mkdir -p $(CURDIR)/tmp/vim; \
		cp $(HOME)/.vimrc $(CURDIR)/tmp/bash/.vimrc && rm $(HOME)/.vimrc; \
		vim +PlugClean +qall
		rm $(CURDIR)/tmp/vim/breadcrums; \
	fi
	rm $(HOME)/.tmux.conf.local
	rm -r $(HOME)/.tmux $(HOME)/.vim
	@echo "Done! (cleaning)"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
