#include "plasma_reader.h"

#include <arrow/util/logging.h>

std::string ToString(ReadOrder order) {
  return (order == SEQUENTIAL) ? "Sequential" : "Random";
}

ReadOrder FromString(const std::string &order_str) {
  if (order_str == "sequential") {
    return ReadOrder::SEQUENTIAL;
  } else if (order_str == "random") {
    return ReadOrder::RANDOM;
  }
  throw std::invalid_argument("Unknown ReadOrder: " + order_str);
}

PlasmaReader::PlasmaReader(const std::string &sock,
                           size_t num_objects,
                           size_t object_size,
                           size_t start_idx,
                           ReadOrder read_order)
  : BenchmarkRunner("Plasma Reader " + ToString(read_order), num_objects, object_size, start_idx),
    read_order_(read_order),
    sock_(sock) {
  ARROW_CHECK_OK(client_.Connect(sock_));
}

size_t PlasmaReader::Run() {
  uint64_t latency_sum = 0;
  size_t num_ops = 0;
  plasma::ObjectID id;
  memset(id.mutable_data(), 0, static_cast<size_t>(plasma::ObjectID::size()));
  auto t0 = NowUs();
  uint64_t t1;
  for (size_t i = start_idx_; i < start_idx_ + num_objects_ && ((t1 = NowUs()) - t0) < TIME_LIMIT_US; ++i) {
    std::vector<plasma::ObjectBuffer> data;
    auto k = Key(i);
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
    ++num_ops;
  }
  avg_latency_ = (double) latency_sum / num_ops;
  throughput_ = (double) num_ops / (t1 - t0);
  return num_ops;
}

size_t PlasmaReader::Key(size_t i) const {
  if (read_order_ == SEQUENTIAL) {
    return i;
  }
  return Random<size_t>(start_idx_, start_idx_ + num_objects_);
}
