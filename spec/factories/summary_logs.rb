FactoryBot.define do
  factory :summary_log do
    project { nil }
    content { "MyText" }
    log_date { "2026-01-14" }
    status { "MyString" }
  end
end
