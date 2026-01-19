FactoryBot.define do
  factory :gitlab_config do
    project { nil }
    base_url { "MyString" }
    access_token { "MyString" }
  end
end
