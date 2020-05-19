#!/bin/sh
#
# script.sh
#
#
PATH_PROJECT=/archive/machines
#PATH_PROJECT=~/fs
init() {
    echo "init"
    mkdir -p $PATH_PROJECT

}

fetch() {
    echo "fetch"
    mkdir -p $PATH_PROJECT${2}
    cd $PATH_PROJECT${2}
    case "${1:-}" in
        "docker" )
            sudo docker create --name ${2} ${2}
            sudo docker export --output="${2}_fs.tar" ${2}
            sudo docker rm -f ${2}
            sudo tar -xf "${2}_fs.tar"
            sudo rm "${2}_fs.tar"
            ;;
    esac
    echo "fs fetched from ${1}"
}

link() {
    echo "link"
    [ -d $3 ] && { # path to dir
        PATH_DEST_ABS=$(realpath $3)/$2
    } || { # path to file
        PATH_DEST_ABS=$(dirname $3)/$(basename $3)
    }
    ln -s $PATH_SCRIPT $PATH_DEST_ABS
}

link_resolve() {
    [ -z "$CONTPATH" ] && {
        CONTAINERS=$(sudo ls $PATH_PROJECT)
    } || {
        CONTAINERS=$(echo $CONTPATH | tr ':' ' ')
    }
    cnt_cmd=($(echo $(basename $0) | sed 's/::/ /'))
    [ ${#cnt_cmd[@]} -lt 2 ] && {
        cmd=$(basename $0)
        IPATH=$PATH
        for cnt in $(echo $CONTAINERS | nl | sort -r | cut -f2); do
            IPATH="$PATH_PROJECT/$cnt/bin:$IPATH"
        done
        PATH=$IPATH which $cmd > /dev/null
        cnt_cmd=($cnt $cmd)
    }
    echo ${cnt_cmd[@]}
    run ${cnt_cmd[*]} $@
}

run() {
    echo "run"
    container=${1}
    shift
    sudo systemd-nspawn -q -UM $container -D $PATH_PROJECT/$container $@
}

print_help() {
    printf "Usage : $(basename $0) <Operation> <Param>
    Operations :
        init    : init ....
        fetch   : fetch fs from docker or .....
        link    : link binaries from container to path
        run     : run a command \n"
}

if [ "$(basename $0)" != script.sh ]; then
    link_resolve $@
else
    PATH_SCRIPT=$(realpath $0)
    operation="${1:-}"
    [ -z "$operation" ] || shift
    case $operation in
        "init" )
            init $@
            ;;
        "fetch" )
            fetch $@
            ;;
        "link" )
            link $@
            ;;
        "run" )
            run $@
            ;;
        *)
            print_help
            ;;
    esac
fi

trap '' EXIT
exit 0
