#ifndef PLASMA_BENCH_THREADED_RUNNER_H
#define PLASMA_BENCH_THREADED_RUNNER_H

#include <thread>
#include "benchmark_runner.h"

template<typename Runner>
class ThreadedRunner : public BenchmarkRunner {
 public:
  static_assert(std::is_base_of<BenchmarkRunner, Runner>::value,
                "Threaded runner template argument must be a BenchmarkRunner");
  ThreadedRunner(const std::string &plasma_sock, size_t num_threads, size_t num_objects, size_t object_size)
      : BenchmarkRunner("Threaded Runner"), num_threads_(num_threads) {
    for (size_t i = 0; i < num_threads_; ++i) {
      runners_.push_back(std::make_shared<Runner>(plasma_sock, num_objects, object_size, i * num_objects));
    }
  }

  virtual ~ThreadedRunner() = default;

  size_t Run() override {
    std::cerr << "Threaded benchmark with " << num_threads_ << " threads..." << std::endl;
    std::vector<std::thread> threads;
    std::vector<std::exception_ptr> eptrs(num_threads_, nullptr);
    std::vector<size_t> num_ops(num_threads_, 0);
    for (size_t i = 0; i < num_threads_; ++i) {
      threads.emplace_back([i, &num_ops, &eptrs, this] {
        try {
          num_ops[i] = runners_[i]->Run();
        } catch (std::exception &) {
          eptrs[i] = std::current_exception();
        }
      });
    }

    double latency_sum = 0;
    size_t tot_ops = 0;
    for (size_t i = 0; i < num_threads_; ++i) {
      if (threads[i].joinable())
        threads[i].join();
      if (eptrs[i]) {
        std::rethrow_exception(eptrs[i]);
      }
      throughput_ += runners_[i]->Throughput();
      latency_sum += runners_[i]->AvgLatency();
      tot_ops += num_ops[i];
    }
    avg_latency_ = latency_sum / num_threads_;
    return tot_ops;
  }

 private:
  std::vector<std::shared_ptr<BenchmarkRunner>> runners_;
  size_t num_threads_;
};

#endif //PLASMA_BENCH_THREADED_RUNNER_H
