module Btce
  class PublicAPI < API
    OPERATIONS = %w(fee ticker trades depth)

    class << self
      def get_pair_operation_json(pair, operation)
        raise ArgumentError if not API::CURRENCY_PAIRS.include? pair
        raise ArgumentError if not OPERATIONS.include? operation
        get_json({ :url => "https://#{API::BTCE_DOMAIN}/api/2/#{pair}/#{operation}" })
      end

      OPERATIONS.each do |operation|
        class_eval %{
          def get_pair_#{operation}_json(pair)
            get_pair_operation_json pair, "#{operation}"
          end
        }

        API::CURRENCY_PAIRS.each do |pair|
          class_eval %{
            def get_#{pair}_#{operation}_json
              get_pair_#{operation}_json "#{pair}"
            end
          }
        end
      end
    end
  end
end