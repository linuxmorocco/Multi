#!/bin/sh
#
# script.sh
#
#
init() {
	echo "init"
}

fetch() {
	echo "fetch"
}

link() {
	echo "link"
}
run() {
	echo "run"
}
print_help() {
	echo "print help"
}

case "${1:-}" in
	"init" )
		init
	;;
	"fetch" )
		fetch
	;;
	"link" )
		link
	;;
	"run" )
		run
	;;
	*)
		print_help
	;;
esac

trap '' EXIT
exit 0
