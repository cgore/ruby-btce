module Btce
  class API
    BTCE_DOMAIN = "btc-e.com"
    CURRENCY_PAIRS = %w(btc_usd
                        btc_eur
                        btc_rur
                        eur_usd
                        ftc_btc
                        ltc_btc
                        ltc_eur
                        ltc_rur
                        ltc_usd
                        nmc_btc
                        nmc_usd
                        nvc_btc
                        nvc_usd
                        ppc_btc
                        trc_btc
                        usd_rur
                        xpm_btc)
    CURRENCIES = CURRENCY_PAIRS.map {|pair| pair.split("_")}.flatten.uniq.sort
    MAX_DIGITS = {
      "btc_usd" => 3,
      "btc_eur" => 3,
      "btc_rur" => 4,
      "eur_usd" => 4,
      "ftc_btc" => 4,
      "ltc_btc" => 5,
      "ltc_eur" => 6,
      "ltc_rur" => 4,
      "ltc_usd" => 6,
      "nmc_btc" => 4,
      "nmc_usd" => 6,
      "nvc_btc" => 4,
      "nvc_usd" => 4,
      "ppc_btc" => 4,
      "trc_btc" => 6,
      "usd_rur" => 4,
      "xpm_btc" => 6
    }

    class << self
      def get_https(opts={})
        raise ArgumentError if not opts[:url].is_a? String
        uri = URI.parse opts[:url]
        http = Net::HTTP.new uri.host, uri.port
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        if opts[:params].nil?
          request = Net::HTTP::Get.new uri.request_uri
        else
          # If sending params, then we want a post request for authentication.
          request = Net::HTTP::Post.new uri.request_uri
          request.add_field "Key", opts[:key]
          request.add_field "Sign", opts[:signed]
          request.set_form_data opts[:params]
        end
        response = http.request request
        response.body
      end

      def get_json(opts={})
        result = get_https(opts)
        if not result.is_a? String or not result.valid_json?
          raise RuntimeError, "Server returned invalid data."
        end
        JSON.load result
      end
    end
  end
end

require 'btce/api/public_api'
require 'btce/api/trade_api'
require 'btce/api/operations'