# frozen_string_literal: true

task restart_jobs: :environment do
  jobs = Resque.size "default"
  working = Resque.working
  pending = QueueItem.pending
  should_run = (jobs.zero? && working.count.zero? && pending.count.positive?)
  message = "Active workers or no pending jobs; will not start any."
  message = "Pending jobs and idle queue; will attempt to restart." if should_run

  Rails.logger.info <<~BLOCKMSG
    Scanning for lost ingest jobs...
        Jobs in default queue: #{jobs}
        Workers active: #{working.count}
        QueueItems pending: #{pending.count}
    #{message}
  BLOCKMSG

  if should_run
    qi = pending.first
    Rails.logger.info "Restarting apparent lost job: QI: #{qi.id}, P: #{qi.package.id}, EID: #{qi.package.external_id}"
    BagMoveJob.perform_later(qi)
  end
end
