class SyncCalendarJob < ApplicationJob
  queue_as :critical

  def perform(user_id)
    user = User.find_by(id: user_id)
    if user.blank?
      Rails.logger.info("SyncCalendarJob: User #{user_id} not found.")
      return
    end

    Calendar::Sync.new(user).call
  end
end
