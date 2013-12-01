module Btce
  class Ticker < PublicOperation
    def initialize(pair)
      super 'ticker', pair
    end

    JSON_METHODS = %w(high low avg vol vol_cur last buy sell server_time)

    JSON_METHODS.each do |method|
      class_eval %{
        def #{method}
          json["ticker"]["#{method}"] if json["ticker"] and json["ticker"].is_a? Hash
        end
      }
    end

    alias_method :bid, :buy
    alias_method :offer, :sell
    alias_method :ask, :sell
    alias_method :average, :avg
    alias_method :volume, :vol
    alias_method :volume_current, :vol_cur

    def spread
      (offer - bid) / offer
    end

    def spread_percent
      spread * 100.0
    end
  end
end