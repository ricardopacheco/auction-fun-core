# frozen_string_literal: true

module AuctionFunCore
  module Business
    # The TokenGenerator module is responsible for generating interaction tokens
    # used in various parts of the AuctionFun application for authentication and
    # verification purposes, particularly in interactions with system users.
    module TokenGenerator
      # Generates a secure, URL-safe base64 token primarily used for email verification.
      # This method modifies certain characters to avoid common readability issues.
      #
      # @param length [Integer] the desired length of the generated token before modification
      # @return [String] a URL-safe, base64 encoded string suitable for email verification links
      # @example Generating an email token
      #   email_token = AuctionFunCore::Business::TokenGenerator.generate_email_token(20)
      #   puts email_token  # Output example: "V4Ph2wkJG_bRzs_zuGyJ"
      def self.generate_email_token(length = 20)
        rlength = (length * 3) / 4
        SecureRandom.urlsafe_base64(rlength).tr("lIO0", "sxyz")
      end

      # Generates a numerical token used for phone verification processes.
      # The token is zero-padded to ensure it meets the required length.
      #
      # @param length [Integer] the desired length of the numerical token
      # @return [String] a string of digits, zero-padded to the specified length
      # @example Generating a phone token
      #   phone_token = AuctionFunCore::Business::TokenGenerator.generate_phone_token(6)
      #   puts phone_token  # Output example: "045673"
      def self.generate_phone_token(length = 6)
        rand(0o00000..999_999).to_s.rjust(length, "0")
      end
    end
  end
end
