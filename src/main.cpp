#include <iostream>
#include "plasma_writer.h"
#include "plasma_reader.h"

int main(int argc, char *argv[]) {
  if (argc < 4) {
    std::cerr << "Usage: " << argv[0] << " [plasma-socket] [num-objects] [object-size]" << std::endl;
    return 0;
  }
  std::string plasma_sock = std::string(argv[1]);
  std::size_t num_objects = std::stoull(argv[2]);
  std::size_t object_size = std::stoull(argv[3]);

  std::cerr << "Running write benchmark..." << std::endl;
  PlasmaWriter writer(plasma_sock, num_objects, object_size);
  writer.Run();

  writer.LogResults(std::cerr);

  std::cerr << "Running read benchmark..." << std::endl;
  PlasmaReader reader(plasma_sock, num_objects, object_size);
  reader.Run();

  reader.LogResults(std::cerr);

  return 0;
}