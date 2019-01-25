#include <iostream>
#include "plasma_writer.h"
#include "plasma_reader.h"

ReadOrder FromString(const std::string& order_str) {
  if (order_str == "sequential") {
    return ReadOrder::SEQUENTIAL;
  } else if (order_str == "random") {
    return ReadOrder::RANDOM;
  }
  throw std::invalid_argument("Unknown ReadOrder: " + order_str);
}

int main(int argc, char *argv[]) {
  if (argc < 4) {
    std::cerr << "Usage: " << argv[0] << " plasma-socket num-objects object-size [read-order]" << std::endl;
    return 0;
  }
  std::string plasma_sock = std::string(argv[1]);
  std::size_t num_objects = std::stoull(argv[2]);
  std::size_t object_size = std::stoull(argv[3]);
  ReadOrder order = RANDOM;
  if (argc == 5) {
    order = FromString(argv[4]);
  }

  std::cerr << "Running write benchmark..." << std::endl;
  PlasmaWriter writer(plasma_sock, num_objects, object_size);
  writer.Run();

  writer.LogResults(std::cerr);

  std::cerr << "Running read benchmark..." << std::endl;
  PlasmaReader reader(plasma_sock, num_objects, object_size, order);
  reader.Run();

  reader.LogResults(std::cerr);

  std::cerr << writer.AvgLatency() << " " << writer.Throughput() << " " << reader.AvgLatency() << " " << reader.Throughput() << std::endl;

  return 0;
}
