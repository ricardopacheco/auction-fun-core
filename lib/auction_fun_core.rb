# frozen_string_literal: true

require_relative "auction_fun_core/version"
require 'zeitwerk'

require_relative '../config/boot'
require_relative '../config/application'

module AuctionFunCore
  class Error < StandardError; end

  def self.root
    File.expand_path '..', __dir__
  end

  autoload :Application, Pathname.new(File.expand_path('../config/application', __dir__))
end
