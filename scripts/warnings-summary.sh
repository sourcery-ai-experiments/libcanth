#!/usr/bin/env bash

set +e

compilers=("$@");
(( ${#compilers[@]} )) || compilers=(
  clang-{6.0,7,8,9,10,11,12,13,14,15,16,17,18,19}
  gcc-{7,8,9,10,11,12,13,14});

printf -vh '%010d+%061d'; h="${h//0/-}";

echo "$h";
for x in "${compilers[@]}"; do
  cxx_="${x/#gcc/g}";
  cxx_="${cxx_/-/++-}";
  y=$(eval make -j$(nproc) '-s -C src debug=1 CC='"'$x'"' CXX='"'$cxx_'"' '{'clean >/dev/null;'$'\n''make','-j1 2>&1 | grep -E "warning.+\[[-]W[^]]+\]" | sed -E "s/\x1b\[[0-9\;]*m//g;s/^([^:]*\/)?([^\/:]+):.+\[-W/\2\t[-W/" | sort | uniq -c | sort -h'});
  (( ${#y} == 0 )) || { echo "$y" | sed "s/^/$(printf '%-9s |' "$x")/"; echo "$h"; };
done
