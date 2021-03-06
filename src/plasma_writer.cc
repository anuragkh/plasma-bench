#include "plasma_writer.h"

#include <arrow/util/logging.h>

PlasmaWriter::PlasmaWriter(const std::string &sock, size_t num_objects, size_t object_size, size_t start_idx)
    : BenchmarkRunner("Plasma Writer", num_objects, object_size, start_idx),
      sock_(sock) {
  buf_ = new uint8_t[object_size];
  for (size_t i = 0; i < object_size; ++i) {
    buf_[i] = 1;
  }
  ARROW_CHECK_OK(client_.Connect(sock_));
}

size_t PlasmaWriter::Run() {
  size_t num_ops = 0;
  uint64_t latency_sum = 0;
  plasma::ObjectID id;
  memset(id.mutable_data(), 0, static_cast<size_t>(plasma::ObjectID::size()));
  auto t0 = NowUs();
  for (size_t i = start_idx_; i < start_idx_ + num_objects_; ++i) {
    *(reinterpret_cast<size_t*>(id.mutable_data())) = i;
    std::shared_ptr<arrow::Buffer> buf;
    auto t00 = NowUs();
    ARROW_CHECK_OK(client_.Create(id, object_size_, nullptr, 0, &buf));
    memcpy(buf->mutable_data(), buf_, object_size_);
    ARROW_CHECK_OK(client_.Seal(id));
    ARROW_CHECK_OK(client_.Release(id));
    auto t01 = NowUs();
    latency_sum += (t01 - t00);
    ++num_ops;
  }
  auto t1 = NowUs();
  avg_latency_ = (double) latency_sum / num_ops;
  throughput_ = (double) num_ops / (t1 - t0);
  return num_ops;
}
