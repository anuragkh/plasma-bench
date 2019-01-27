#include <iostream>
#include <cassert>
#include "plasma_writer.h"
#include "plasma_reader.h"
#include "threaded_runner.h"

int main(int argc, char *argv[]) {
  if (argc < 5) {
    std::cerr << "Usage: " << argv[0] << " plasma-socket num-threads num-objects object-size" << std::endl;
    return 0;
  }
  std::string plasma_sock = std::string(argv[1]);
  std::size_t num_threads = std::stoull(argv[2]);
  std::size_t num_objects = std::stoull(argv[3]);
  std::size_t object_size = std::stoull(argv[4]);

  ThreadedRunner<PlasmaWriter> writer(plasma_sock, num_threads, num_objects, object_size);
  assert(writer.Run() > 0);

  ThreadedRunner<PlasmaReader> reader(plasma_sock, num_threads, num_objects, object_size);
  assert(reader.Run() > 0);

  std::cerr << writer.AvgLatency() << " " << writer.Throughput() << " "
            << reader.AvgLatency() << " " << reader.Throughput() << std::endl;

  return 0;
}
