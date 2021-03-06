# frozen_string_literal: true

class SamplePlainJob
  include Sidekiq::Worker

  def perform(*_args)
    "My job is simple"
  end
end

class SampleComplexJob
  include Sidekiq::Worker

  def perform(*_args)
    Yabeda.test.whatever.increment({ explicit: true })
    "My job is complex"
  end

  def yabeda_tags
    { implicit: true }
  end
end

class FailingPlainJob
  include Sidekiq::Worker

  def perform(*_args)
    raise "Badaboom"
  end
end

class SampleActiveJob < ActiveJob::Base
  self.queue_adapter = :Sidekiq

  def perform(*_args)
    "I'm doing my job"
  end
end

class FailingActiveJob < ActiveJob::Base
  self.queue_adapter = :Sidekiq
  def perform(*_args)
    raise "Boom"
  end
end
