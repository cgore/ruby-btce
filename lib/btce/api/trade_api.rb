module Btce
  class TradeAPI < API
    if File.exists? 'btce-api-key.yml'
      KEY = YAML::load File.open 'btce-api-key.yml'

      class << self
        def new_from_keyfile
          new key: KEY["key"], secret: KEY["secret"]
        end
      end
    end

    OPERATIONS = %w(getInfo
                    TransHistory
                    TradeHistory
                    OrderList
                    ActiveOrders
                    Trade
                    CancelOrder)


    def initialize(opts={})
      raise ArgumentError unless opts.has_key?(:key) and opts.has_key?(:secret)
      @key = opts[:key]
      @secret = opts[:secret]
    end

    def sign(params)
      # The digest needs to be created.
      hmac = OpenSSL::HMAC.new(@secret,
                               OpenSSL::Digest::SHA512.new)
      params = params.collect {|k,v| "#{k}=#{v}"}.join('&')
      signed = hmac.update params
    end

    def trade_api_call(method, extra)
      params = {"method" => method, "nonce" => nonce}
      if ! extra.empty?
        extra.each do |k,v|
          params[k.to_s] = v
        end
      end
      signed = sign params
      API::get_json({ :url => "https://#{API::BTCE_DOMAIN}/tapi",
                      :key => @key,
                      :params => params,
                      :signed => signed })
    end

    def nonce
      while result = Time.now.to_i and @last_nonce and @last_nonce >= result
        sleep 1
      end
      return @last_nonce = result
    end
    private :nonce

    OPERATIONS.each do |operation|
      class_eval %{
        def #{operation.camelcase_to_snakecase} extra={}
          trade_api_call "#{operation}", extra
        end
      }
    end
  end
end