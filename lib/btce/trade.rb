module Btce
  class Trade
    attr_accessor :json

    JSON_METHODS = %w(date price amount tid price_currency item trade_type)

    attr_accessor *JSON_METHODS.map(&:to_sym)

    class << self
      def new_from_json(json)
        result = Trade.new
        result.json = json
        if json.is_a? Hash
          JSON_METHODS.each do |method|
            instance_eval %{
              result.#{method} = json["#{method}"]
            }
          end
        end
        result
      end
    end
  end
end