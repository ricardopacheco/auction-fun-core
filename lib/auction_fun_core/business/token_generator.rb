# frozen_string_literal: true

module AuctionFunCore
  module Business
    # Responsible for generating interaction tokens with system users for general operations.
    module TokenGenerator
      def self.generate_email_token(length = 20)
        rlength = (length * 3) / 4
        SecureRandom.urlsafe_base64(rlength).tr("lIO0", "sxyz")
      end

      def self.generate_phone_token(length = 6)
        rand(0o00000..999_999).to_s.rjust(length, "0")
      end
    end
  end
end
