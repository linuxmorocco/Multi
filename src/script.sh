#!/bin/sh
#
# script.sh
#
#
PATH_PROJECT=~/fs
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
        link    : link
        run     : run a command \n"
}

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

trap '' EXIT
exit 0
