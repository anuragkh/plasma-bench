#ifndef PLASMA_BENCH_BENCHMARK_RUNNER_H
#define PLASMA_BENCH_BENCHMARK_RUNNER_H

#include <chrono>
#include <cstdint>
#include <iosfwd>
#include <iostream>

class BenchmarkRunner {
 public:
  explicit BenchmarkRunner(const std::string &runner_type)
      : runner_type_(runner_type), throughput_(-1.0), avg_latency_(-1.0) {}

  virtual void Run() = 0;

  double Throughput() const { return throughput_ * 1E6; }

  double AvgLatency() const { return avg_latency_; }

  void LogResults(std::ostream &out) {
    if (throughput_ < 0) {
      out << "Must call Run() before LogResults()" << std::endl;
    }
    out << runner_type_ << " results: " << std::endl;
    out << "Throughput: " << Throughput() << " ops/s" << std::endl;
    out << "Latency: " << AvgLatency() << " us" << std::endl;
  }

 protected:
  static uint64_t NowUs() {
    using namespace ::std::chrono;
    time_point<system_clock> now = system_clock::now();
    return static_cast<uint64_t>(duration_cast<microseconds>(now.time_since_epoch()).count());
  }

  std::string runner_type_;
  double throughput_;
  double avg_latency_;
};

#endif //PLASMA_BENCH_BENCHMARK_RUNNER_H
