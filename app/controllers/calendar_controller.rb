class CalendarController < ApplicationController
  before_action :authenticate_user!, only: :index
  before_action :sync_calendar, only: :index

  def index
    @events = current_user
              .events
              .then { |records| serialize(records, { each_serializer: ::EventSerializer }) }
  end

  private

  def sync_calendar
    SyncCalendarJob.perform_now(current_user.id) if Rails.env.development?
  end
end
