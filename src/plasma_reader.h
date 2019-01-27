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

std::string ToString(ReadOrder order);
ReadOrder FromString(const std::string &order_str);

class PlasmaReader : public BenchmarkRunner {
 public:
  PlasmaReader(const std::string &sock,
               size_t num_objects,
               size_t object_size,
               size_t start_idx,
               ReadOrder read_order = ReadOrder::RANDOM);

  virtual ~PlasmaReader() = default;

  size_t Run() override;

 private:
  size_t Key(size_t i) const;

  ReadOrder read_order_;
  std::string sock_;

  plasma::PlasmaClient client_;
};

#endif //PLASMA_BENCH_PLASMA_READER_H
