#!/usr/bin/env bash

multiply() {
  gawk -vp=$1 -vq=$2 'BEGIN{printf "%d", p * q}'
}

external_store=${1:-""}

plasma_exec="./build/external/arrow-install/bin/plasma_store_server"
bench_exec="./build/plasma_bench"
plasma_sock="/tmp/sock.0"
obj_size=("1024" "32768" "1048576" "33554432")
plasma_mem=("10485760" "104857600" "104857600" "1073741824")

if [[ "$external_store" == "" ]]; then
  ratio=("0.9" "1.0")
  result_prefix="result"
  log_prefix="plasma"
  EXTERNAL_STORE_OPTS=""
else
  ratio=("0.9" "1.0" "1.1" "1.2" "1.5" "2.0")
  result_prefix="result_${external_store%%:*}"
  log_prefix="plasma_${external_store%%:*}"
  EXTERNAL_STORE_OPTS="-e ${external_store}"
fi

echo "Ratios: ${ratio[@]}"
echo "Object sizes: ${obj_size[@]}"
echo "Plasma memory: ${plasma_mem[@]}"

start_plasma_store() {
  ${plasma_exec} -s ${plasma_sock} -m $1 ${EXTERNAL_STORE_OPTS} 2>${log_prefix}_$2_$3.stderr &
  pid=$!
}

stop_plasma_store() {
  kill -TERM ${pid}
  wait ${pid}
}

for r in "${ratio[@]}"; do
  for i in 0 1 2 3; do
    mem_to_fill=`multiply ${plasma_mem[$i]} ${r}`
    num_obj=$(( mem_to_fill / obj_size[$i] ))
    echo "Benchmark with ratio=${r}, object_size=${obj_size[$i]}, num_obj=${num_obj}"
    start_plasma_store ${plasma_mem[$i]} ${r} ${obj_size[$i]}
    ${bench_exec} ${plasma_sock} 1 ${num_obj} ${obj_size[$i]} 2>${result_prefix}_${r}_${obj_size[$i]}
    stop_plasma_store
  done
done
