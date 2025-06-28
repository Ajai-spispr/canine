module Scheduled
  class CheckClusterStatusJob < ApplicationJob
    queue_as :default

    def perform
      puts "Job ran from puts"
      Rails.logger.info "Job ran from rails logger!"
    end
  end
end 