# frozen_string_literal: true

IdleMailer.config do |config|
  config.delivery_method = :test
end

RSpec.configure do |config|
  config.include IdleMailer::Testing::Helpers

  config.after :each do
    IdleMailer::Testing.clear_mail!
  end
end
