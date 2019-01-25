#include "plasma_writer.h"

#include <arrow/util/logging.h>

PlasmaWriter::PlasmaWriter(const std::string &sock, size_t num_objects,
                           size_t object_size)
    : BenchmarkRunner("Plasma Writer"),
      num_objects_(num_objects),
      object_size_(object_size),
      sock_(sock) {
  buf_ = new uint8_t[object_size];
  for (size_t i = 0; i < object_size; ++i) {
    buf_[i] = 1;
  }
  ARROW_CHECK_OK(client_.Connect(sock_));
}

void PlasmaWriter::Run() {
  uint64_t latency_sum = 0;
  auto t0 = NowUs();
  for (size_t i = 0; i < num_objects_; ++i) {
    plasma::ObjectID id;
    *(reinterpret_cast<size_t*>(id.mutable_data())) = i;
    std::shared_ptr<arrow::Buffer> buf;
    auto t00 = NowUs();
    ARROW_CHECK_OK(client_.Create(id, object_size_, nullptr, 0, &buf));
    memcpy(buf->mutable_data(), buf_, object_size_);
    ARROW_CHECK_OK(client_.Seal(id));
    auto t01 = NowUs();
    latency_sum += (t01 - t00);
  }
  auto t1 = NowUs();
  avg_latency_ = (double) latency_sum / num_objects_;
  throughput_ = (double) num_objects_ / (t1 - t0);
}
