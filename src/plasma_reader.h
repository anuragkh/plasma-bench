#ifndef PLASMA_BENCH_PLASMA_READER_H
#define PLASMA_BENCH_PLASMA_READER_H

#include <cstdint>
#include <cstddef>
#include <plasma/client.h>
#include <string>

#include "benchmark_runner.h"

enum ReadOrder {
  SEQUENTIAL = 0,
  RANDOM = 1
};

class PlasmaReader : public BenchmarkRunner {
 public:
  PlasmaReader(const std::string &sock,
               size_t num_objects,
               size_t object_size,
               ReadOrder read_order = ReadOrder::RANDOM);

  virtual ~PlasmaReader() = default;

  void Run() override;

 private:
  size_t Key(size_t i) const;

  size_t num_objects_;
  size_t object_size_;
  ReadOrder read_order_;
  std::string sock_;

  plasma::PlasmaClient client_;
};

#endif //PLASMA_BENCH_PLASMA_READER_H
