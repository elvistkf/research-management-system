#!/bin/zsh

# Custom research directory provided?
custom_RMS_ROOT=${RMS_ROOT:+yes}

# Default settings
RMS=${RMS:-$HOME/.rms}
REPO=${REPO:-elvistkf/research-management-system}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-main}

# Colours 
RED=$(printf '\033[31m')
YELLOW=$(printf '\033[33m')
BLUE=$(printf '\033[34m')
BOLD=$(printf '\033[1m')
CYAN="\033[0;36m"
RESET="\033[0m"

function command_exists() {
    command -v "$@" > /dev/null 2>&1
}

function format_error() {
    echo "${BOLD}${RED}Error: $* ${RESET}" >&2
}

function format_warning() {
    echo "${BOLD}${YELLOW}Warning: $* ${RESET}" >&2
}

function setup_rms() {
    # Check if git is installed
    command_exists git || {
        format_error "git is not installed"
        exit 1
    }
	
	#-------------------------------------------------------------------------
	# for production only. disabled for development
	# 
    # Clone git repo
    # git init --quiet $RMS
    # cd $RMS && \
    # git remote add origin $REMOTE && \
    # git fetch --depth=1 origin && \
    # git checkout -b $BRANCH origin/$BRANCH || {
    # 	format_error "git clone repo of rms failed"
    # 	exit 1
    # }
	#-------------------------------------------------------------------------
	
	#-------------------------------------------------------------------------
	# for development only
	rm -r -f $RMS
	mkdir $RMS
	cd ~/Cloud/Developer/research-management-system
	ls
	echo $RMS
	cp -a ~/Cloud/Developer/research-management-system/ $RMS
	
	grep -q "export RMS=" ~/.zshrc || echo "export RMS=$RMS" >> $HOME/.zshrc
	grep -q "source ${RMS}/.rmsrc" ~/.zshrc || echo "source ${RMS}/.rmsrc" >> $HOME/.zshrc
	grep -q "source ${RMS}/src/rms.sh" ~/.zshrc || echo "source ${RMS}/src/rms.sh" >> $HOME/.zshrc
	#-------------------------------------------------------------------------
}

function setup_research_folder() {
    local root_dir
    if [ "$custom_RMS_ROOT" != "yes" ]; then
        echo "${CYAN}Please enter your research folder directory path."
        read root_dir
        root_dir="${root_dir//\~/$HOME}"
    else
        root_dir="${RMS_ROOT//\~/$HOME}"
    fi
    [ -d $root_dir ] || {
		echo ""
        echo "The provided directory ${BLUE}$root_dir${CYAN} does not exist. Do you want to create it now?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes)
                    mkdir $root_dir
                break;;
                No)
                    format_warning "Research folder does not exist and has not been created."
                break;;
            esac
        done
    }
    echo "export _RMS_ROOT=$root_dir" >> $RMS/.rmsrc

    # target_file=$HOME/.zshrc
    target_file=$RMS/.rmsrc
    echo "fpath=($RMS/autocomplete" '$fpath)' >> $target_file
    echo "" >> $target_file
    echo "compdef _rmsprojspecific rmscd rmsresetbib" >> $target_file
    echo "compdef _rmstexspecific rmslaunchtex rmsviewpdf" >> $target_file
    echo "" >> $target_file
    echo "autoload -U compinit" >> $target_file
    echo "compinit" >> $target_file
    echo "" >> $target_file
    echo "zstyle ':completion:*' menu select=2" >> $target_file

	echo "${CYAN}The default research folder structure is as follows:"
	echo "    \uf115 /"
	echo "    \u221f \uf115 Project"
	echo "      \u221f \uf07c {Project Folders}"
	echo "        \u221f \uf115 Code"
	echo "        \u221f \uf115 Paper"
	echo "        \u221f \uf115 Presentation"
	echo "    \u221f \uf115 Bibliography"
	echo "      \u221f \uf115 Papers"
	echo "    \u221f \uf115 LatexTemplate"
	echo "      \u221f \uf07c {Template Folders}"
	echo "The folder structure can be customised in ${RMS}/.rmsfs${RESET}"

	echo "source $RMS/.rmsfs" >> $RMS/.rmsrc
	
    echo "_RMS_PROJECT=Project" >> $RMS/.rmsfs
    echo "_RMS_BIB=Bibliography" >> $RMS/.rmsfs
    echo "_RMS_TEMPLATE=LatexTemplate" >> $RMS/.rmsfs
    echo "_RMS_TEMPLATE_DEFAULT=ieeeconf" >> $RMS/.rmsfs
    echo "_RMS_PROJECT_PAPER=Paper" >> $RMS/.rmsfs
    echo "_RMS_PROJECT_CODE=Code" >> $RMS/.rmsfs
    echo "_RMS_PROJECT_PRESENTATION=Presentation" >> $RMS/.rmsfs
    echo "#_RMS_PROJECT_OTHERS=" >> $RMS/.rmsfs

}

function main() {
    setup_rms
    setup_research_folder
}

main $@