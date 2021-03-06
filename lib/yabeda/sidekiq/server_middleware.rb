# frozen_string_literal: true

module Yabeda
  module Sidekiq
    # Sidekiq worker middleware
    class ServerMiddleware
      # rubocop: disable Metrics/AbcSize, Metrics/MethodLength:
      def call(worker, job, queue)
        custom_tags = Yabeda::Sidekiq.custom_tags(worker, job).to_h
        labels = Yabeda::Sidekiq.labelize(worker, job, queue).merge(custom_tags)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        begin
          job_instance = ::Sidekiq::Job.new(job)
          Yabeda.sidekiq_job_latency.measure(labels, job_instance.latency)
          Yabeda.with_tags(**custom_tags) do
            yield
          end
          Yabeda.sidekiq_jobs_success_total.increment(labels)
        rescue Exception # rubocop: disable Lint/RescueException
          Yabeda.sidekiq_jobs_failed_total.increment(labels)
          raise
        ensure
          Yabeda.sidekiq_job_runtime.measure(labels, elapsed(start))
          Yabeda.sidekiq_jobs_executed_total.increment(labels)
        end
      end
      # rubocop: enable Metrics/AbcSize, Metrics/MethodLength:

      private

      def elapsed(start)
        (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start).round(3)
      end
    end
  end
end
