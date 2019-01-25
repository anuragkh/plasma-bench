#include "plasma_reader.h"

#include <arrow/util/logging.h>

PlasmaReader::PlasmaReader(const std::string &sock, size_t num_objects, size_t object_size)
  : BenchmarkRunner("Plasma Reader"),
    num_objects_(num_objects),
    object_size_(object_size),
    sock_(sock) {
  ARROW_CHECK_OK(client_.Connect(sock_));
}

void PlasmaReader::Run() {
  uint64_t latency_sum = 0;
  plasma::ObjectID id;
  memset(id.mutable_data(), 0, static_cast<size_t>(plasma::ObjectID::size()));
  auto t0 = NowUs();
  for (size_t i = 0; i < num_objects_; ++i) {
    std::vector<plasma::ObjectBuffer> data;
    *(reinterpret_cast<size_t*>(id.mutable_data())) = i;
    auto t00 = NowUs();
    ARROW_CHECK_OK(client_.Get({id}, -1, &data));
    auto t01 = NowUs();
    latency_sum += (t01 - t00);
    ARROW_CHECK(data.size() == 1 && data[0].data->size() == static_cast<int64_t>(object_size_));
  }
  auto t1 = NowUs();
  avg_latency_ = (double) latency_sum / num_objects_;
  throughput_ = (double) num_objects_ / (t1 - t0);
}

