# frozen_string_literal: true

module Calendar
  class Sync < BaseService
    def initialize(user)
      super

      @user = user
      @sync_info = SyncInfo.find_or_create_by(user: user)
    end

    def call
      refresh_token!

      if @sync_info.page_token.present?
        continue_sync(@sync_info.page_token)
      else
        full_sync(@sync_info.sync_token)
      end
    end

    private

    attr_reader :user, :sync_info

    def refresh_token!
      TokenRefresher.new(user).call
    end

    def continue_sync(page_token)
      while page_token.present?
        result = EventsGateway::List.new(token: user.reload.token).fetch(page_token: page_token)
        proccess_items(result.items)

        page_token = result.next_page_token
        finish_sync(result.next_sync_token)
      end
    end

    def full_sync(sync_token)
      result = EventsGateway::List.new(token: user.reload.token).fetch(sync_token: sync_token)
      proccess_items(result.items)

      continue_sync(result.next_page_token)
      finish_sync(result.next_sync_token)
    end

    def finish_sync(sync_token)
      return if sync_token.blank?

      sync_info.update(sync_token: sync_token, page_token: nil)
    end

    CALENDAR_EVENT_KIND = 'calendar#event'

    def proccess_items(items) # rubocop:disable Metrics/MethodLength
      records = items.map do |item|
        next if item[:kind] != CALENDAR_EVENT_KIND

        {
          gid: item[:id],
          start: parse_time(item[:start]),
          end: parse_time(item[:end]),
          summary: item[:summary],
          description: item[:description],
          user_id: user.id,
          created_at: Time.current,
          updated_at: Time.current
        }
      end.compact
      Event.upsert_all(records, unique_by: :gid) if records.present? # rubocop:disable Rails/SkipsModelValidations
    end

    def parse_time(time_info)
      case time_info.symbolize_keys
      in date_time:, time_zone:
        Time.find_zone(time_zone)
      in date_time:
        Time.zone
      end.parse(date_time)
    end
  end
end
