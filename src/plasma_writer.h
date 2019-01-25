#ifndef PLASMA_BENCH_PLASMA_WRITER_H
#define PLASMA_BENCH_PLASMA_WRITER_H

#include <cstdint>
#include <cstddef>
#include <plasma/client.h>
#include <string>

#include "benchmark_runner.h"

class PlasmaWriter : public BenchmarkRunner {
 public:
  PlasmaWriter(const std::string &sock, size_t num_objects, size_t object_size);

  void Run() override;

 private:
  size_t num_objects_;
  size_t object_size_;
  std::string sock_;
  uint8_t* buf_;

  plasma::PlasmaClient client_;
};

#endif //PLASMA_BENCH_PLASMA_WRITER_H
