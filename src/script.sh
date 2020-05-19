#!/bin/sh
#
# script.sh
#
#
PATH_PROJECT=~/fs/
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
    cmd=${2}" "${3}
    sudo systemd-nspawn --machine ${1} --directory $PATH_PROJECT${1} $cmd
}
print_help() {
    printf "Usage : ./script <Operation> <Param>
    Operations :
        init    : init ....
        fetch   : fetch fs from docker or .....
        link    : link
        run     : run a command "
}

case "${1:-}" in
    "init" )
        init ${2}
    ;;
    "fetch" )
        fetch ${2} ${3}
    ;;
    "link" )
        link
    ;;
    "run" )
        run ${2} ${3} ${4}
    ;;
    *)
        print_help
    ;;
esac

trap '' EXIT
exit 0
