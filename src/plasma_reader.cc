#include "plasma_reader.h"

#include <arrow/util/logging.h>

std::string ToString(ReadOrder order) {
  return (order == SEQUENTIAL) ? "Sequential" : "Random";
}

PlasmaReader::PlasmaReader(const std::string &sock,
                           size_t num_objects,
                           size_t object_size,
                           size_t start_idx,
                           ReadOrder read_order)
  : BenchmarkRunner("Plasma Reader " + ToString(read_order), num_objects, object_size, start_idx),
    sock_(sock) {
  ARROW_CHECK_OK(client_.Connect(sock_));
}

void PlasmaReader::Run() {
  uint64_t latency_sum = 0;
  plasma::ObjectID id;
  memset(id.mutable_data(), 0, static_cast<size_t>(plasma::ObjectID::size()));
  std::cerr << "Starting read benchmark in range " << start_idx_ << " to " << start_idx_ + num_objects_;
  auto t0 = NowUs();
  for (size_t i = start_idx_; i < start_idx_ + num_objects_; ++i) {
    std::vector<plasma::ObjectBuffer> data;
    auto k = Key(i);
    std::cerr << i << "th key is " << k << std::endl;
    *(reinterpret_cast<size_t*>(id.mutable_data())) = k;
    auto t00 = NowUs();
    ARROW_CHECK_OK(client_.Get({id}, 10000, &data));
    auto t01 = NowUs();
    latency_sum += (t01 - t00);
    ARROW_CHECK(data.size() == 1);
    if (!data[0].data) {
      std::string msg = "Object ID " + id.hex() + " (" +
          std::to_string(*(reinterpret_cast<size_t*>(id.mutable_data()))) + ") not found";
      throw std::runtime_error(msg);
    }
    ARROW_CHECK(data[0].data->size() == static_cast<int64_t>(object_size_));
  }
  auto t1 = NowUs();
  avg_latency_ = (double) latency_sum / num_objects_;
  throughput_ = (double) num_objects_ / (t1 - t0);
}

size_t PlasmaReader::Key(size_t i) const {
  if (read_order_ == SEQUENTIAL)
    return i;
  return Random<size_t>(start_idx_, start_idx_ + num_objects_);
}

