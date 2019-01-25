mem_to_fill=${1:-"4294967296"}
plasma_mem=${2:-"8589934592"}
external_store=${3:-""}

start_plasma_store() {
  m=$1
  n=$2
  s=$3
  es=$4
  if [ "$es" == "" ]; then
    EXTERNAL_STORE_OPTS=""
    f="plasma_${m}_${n}_${s}"
  else
    EXTERNAL_STORE_OPTS="-e $es"
    f="plasma_${es%%:*}_${m}_${n}_${s}"
  fi
  ./build/external/arrow-install/bin/plasma_store_server -f -s /tmp/sock.0 -m $m $EXTERNAL_STORE_OPTS 2>${f}.stderr &
  pid=$!
  sleep 1
}

stop_plasma_store() {
  killall -KILL $pid
  sleep 1
}

if [ "$external_store" == "" ]; then
  result_prefix="result"
else
  result_prefix="result_${external_store%%:*}"
fi

for obj_size in 1024 8192 65536 524288 4194304 33554432; do
  num_obj=$(( mem_to_fill / obj_size ))
  echo "Benchmark with $num_obj objects of size $obj_size"
  start_plasma_store ${plasma_mem} ${num_obj} ${obj_size} ${external_store}
  ./build/plasma_bench /tmp/sock.0 $num_obj $obj_size 2>${result_prefix}_${num_obj}_${obj_size}
  stop_plasma_store
done
