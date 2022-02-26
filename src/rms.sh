#!/bin/zsh

source ${RMS}/src/format.sh

function rmscd() {
    local target_dir
    cd $_RMS_ROOT
    [ $# -eq 1 ] && {
        target_dir="$_RMS_ROOT/$_RMS_PROJECT/$1"
        [ -d $target_dir ] || {
            format_error "${target_dir#.} not found"
            return 1
        }
        cd $target_dir
    }
}

function rmscreate() {
    local root_dir
    local template_dir
    cd $_RMS_ROOT
    
    [ $# -eq 0 ] && {
        format_warning "Project name not provided. Please enter project folder name to continue:"
        read
        root_dir="$_RMS_ROOT/$_RMS_PROJECT/$REPLY"
    } || root_dir="$_RMS_ROOT/$_RMS_PROJECT/$1"
    
    [ $# -eq 2 ] && template_dir="$_RMS_ROOT/$_RMS_TEMPLATE/$2" || template_dir="$_RMS_ROOT/$_RMS_TEMPLATE/$_RMS_TEMPLATE_DEFAULT"
    
    mkdir $root_dir
    mkdir $root_dir/$_RMS_PROJECT_CODE
    mkdir $root_dir/$_RMS_PROJECT_PAPER
    mkdir $root_dir/$_RMS_PROJECT_PRESENTATION
    
    for dir in $(echo $_RMS_PROJECT_OTHERS | tr ";" "\n"); do
        mkdir $root_dir/$dir
    done
    
    cp $template_dir/*.* $root_dir/$_RMS_PROJECT_PAPER
    rmsupdatebib $1
}

function rmsupdatebib() {
    # -v|--verbose)
    # local verbose=1
    # shift # Remove --initialize from processing
    # ;;
    python ${RMS}/src/reformat_bibtex.py ${_RMS_ROOT} ${_RMS_BIB} "ref"

    echo "${CYAN}Bibtex synced to ${RESET}"
    [ $# -eq 1 ] && {
        cp ${_RMS_ROOT}/${_RMS_BIB}/ref_rf.bib \
        ${_RMS_ROOT}/${_RMS_PROJECT}/$1/${_RMS_PROJECT_PAPER}/ref.bib

        echo "    ${CYAN}\uf115 $1${RESET}"
    } || {
        for d in ${_RMS_ROOT}/${_RMS_PROJECT}/*; do
            local paper_success=0
            local presentation_success=0
            [ -d $d/${_RMS_PROJECT_PAPER} ] && {
                cp ${_RMS_ROOT}/${_RMS_BIB}/ref_rf.bib \
                $d/${_RMS_PROJECT_PAPER}/ref.bib
                paper_success=1
            }
            [ -d $d/${_RMS_PROJECT_PRESENTATION} ] && {
                cp ${_RMS_ROOT}/${_RMS_BIB}/ref_rf.bib \
                $d/${_RMS_PROJECT_PRESENTATION}/ref.bib
                presentation_success=1
            }
            [ $paper_success -eq 1 -o $presentation_success -eq 1 ] && {
                echo "    ${CYAN}\uf115 ${d#${_RMS_ROOT}/${_RMS_PROJECT}/}${RESET}"
                # [ $paper_success -eq 1 ] && {
                #     echo "     ${CYAN}\u221f \uf115 ${_RMS_PROJECT_PAPER}${RESET}"
                # }
                # [ $presentation_success -eq 1 ] && {
                #     echo "     ${CYAN}\u221f \uf115 ${_RMS_PROJECT_PRESENTATION}${RESET}"
                # }
                
            }
        done
    }
}

function rmsresetbib() {
    [ $# -eq 0 ] && {
        format_error "Project name not entered."
        return 1
    }
    rm $_RMS_ROOT/$_RMS_PROJECT/$1/$_RMS_PROJECT_PAPER/*.bbl
    rm $_RMS_ROOT/$_RMS_PROJECT/$1/$_RMS_PROJECT_PRESENTATION/*.bbl
}

function rmslaunchtex() {
    [ $# -eq 0 ] && {
        format_error "Project name not entered."
        return 1
    }
    local file_path
}

function rmslistproj() {
    rmscd
    count=0
    for d in ${_RMS_ROOT}/${_RMS_PROJECT}/* ; do
        [ -d $d ] && {
            echo "    ${CYAN}\uf115 ${d#${_RMS_ROOT}/${_RMS_PROJECT}/}${RESET}"
            count=$(( $count + 1 ))
        }
    done
    echo "Summary: $count project folders found."
}