FactoryBot.define do
  factory :user do
    email { "hello@calendar.com" }
    password { SecureRandom.hex(5) }
  end
end
