#!/usr/bin/env bash

set +e

get_lib() {
	local d
	d=$(dirname "$1")      &&
	d=$(realpath -es "$d") &&
	[[ "$d" && -d "$d/" ]] &&
	. "$d/lib.sh"
}

(( ${#compilers[@]} )) || {
	if (( $# )); then
		compilers=("$@")
	else
		get_lib "$0" && get_compilers &&
		(( ${#compilers[@]} )) || exit 1
	fi
}

declare -i ncpu=$(nproc);
((ncpu=ncpu<1 ?1 :ncpu));
declare -i w=$(printf '%s\n' "${compilers[@]}" | wc -L);
printf -vfmt '%%-%ds |%%%%3d %%%%s\\\\t%%%%s\\\\n' "$w";
declare -i e=68-w++;
printf -vh "%0${w}d+%0${e}d";
h="${h//0/-}";

e=0
for cc_ in "${compilers[@]}"; do
  cxx_="${cc_##*g}";
  cxx_="${cc_::${#cc_}-${#cxx_}}++${cxx_#cc}";
  make -j$ncpu -s -C src debug=1 CC="$cc_" CXX="$cxx_" clean >/dev/null 2>&1;
  y=$(make -j1 -s -C src debug=1 CC="$cc_" CXX="$cxx_" 2>&1              |
    grep -E "warning.+\[[-]W[^]]+\]"                                     |
    sed -E "s/\x1b\[[0-9\;]*m//g;s/^([^:]*\/)?([^\/:]+):.+\[-W/\2\t[-W/" |
    sort | uniq -c | sort -h);
  (( ${#y} < 1 )) || {
    printf -vfmt2 "$fmt" "$cc_";
    printf -vout -- "$fmt2" $y
    if (( e++ )); then
      printf -- "%s$h\n" "$out";
    else
      printf -- "$h\n%s$h\n" "$out";
    fi; };
done
