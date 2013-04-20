# Copyright (c) 2013, Christopher Mark Gore,
# Soli Deo Gloria,
# All rights reserved.
#
# 8729 Lower Marine Road, Saint Jacob, Illinois 62281 USA.
# Web: http://cgore.com
# Email: cgore@cgore.com
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# * Neither the name of Christopher Mark Gore nor the names of other
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'json'
require 'monkey-patch'
require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'
require 'yaml'

module Btce
  class API
    BTCE_DOMAIN = "btc-e.com"
    CURRENCIES =  %w(btc
                     usd
                     rur
                     ltc
                     nmc
                     eur
                     nvc)
    CURRENCY_PAIRS = %w(btc_usd
                        btc_eur
                        btc_rur
                        ltc_btc
                        ltc_usd
                        ltc_rur
                        nmc_btc
                        usd_rur
                        eur_usd
                        nvc_btc)
    MAX_DIGITS = {
      "btc_usd" => 3,
      "btc_eur" => 3,
      "btc_rur" => 4,
      "ltc_btc" => 5, 
      "ltc_usd" => 6,
      "ltc_rur" => 4,
      "nmc_btc" => 4,
      "usd_rur" => 4,
      "eur_usd" => 4, 
      "nvc_btc" => 4
    }
    KEY = YAML::load File.open 'btce-api-key.yml'    

    class << self
      def get_https(url, params = nil, sign = nil)
        raise ArgumentError if not url.is_a? String
        uri = URI.parse url
        http = Net::HTTP.new uri.host, uri.port
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        if params.nil?
          request = Net::HTTP::Get.new uri.request_uri
        else
          # If sending params, then we want a post request for authentication.
          request = Net::HTTP::Post.new uri.request_uri
          request.add_field "Key", API::KEY['key']
          request.add_field "Sign", sign
          request.set_form_data params
        end
        response = http.request request
        response.body
      end

      def get_json(url, params = nil, sign = nil)
        result = get_https(url, params, sign)
        if not result.is_a? String or not result.valid_json?
          raise RuntimeError, "Server returned invalid data."
        end
        JSON.load result
      end
    end
  end

  class PublicAPI < API
    OPERATIONS = %w(fee ticker trades depth)

    class << self

      def get_pair_operation_json(pair, operation)
        raise ArgumentError if not API::CURRENCY_PAIRS.include? pair
        raise ArgumentError if not OPERATIONS.include? operation
        get_json "https://#{API::BTCE_DOMAIN}/api/2/#{pair}/#{operation}"
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

  class PublicOperation
    attr_reader :json, :operation, :pair

    def initialize(operation, pair)
      @operation = operation
      @pair = pair
      load_json
    end

    def load_json
      @json = PublicAPI.get_pair_operation_json pair, operation
    end
  end

  class Fee < PublicOperation
    def initialize(pair)
      super 'fee', pair
    end

    def trade
      json["trade"]
    end
  end

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

    alias :average :avg
    alias :volume :vol
    alias :volume_current :vol_cur
  end

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

  class Trades < PublicOperation
    attr_reader :all

    def initialize(pair)
      super 'trades', pair
      load_trades
    end

    def load_trades
      @all = json.map {|trade| Trade.new_from_json trade} if json.is_a? Array
    end
    private :load_trades

    def [] *rest
      all[*rest]
    end
  end

  class Depth < PublicOperation
    def initialize(pair)
      super 'depth', pair
    end
  end

  class TradeAPI < API
    OPERATIONS = %w(getInfo
                    TransHistory
                    TradeHistory
                    OrderList
                    Trade
                    CancelOrder)
 
    class << self
      def sign(params)
        # The digest needs to be created.
        hmac = OpenSSL::HMAC.new(API::KEY['secret'],
                                 OpenSSL::Digest::SHA512.new)
        params = params
          .collect {|k,v| "#{k}=#{v}"}
          .join('&')
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
        get_json "https://#{API::BTCE_DOMAIN}/tapi", params, signed
      end
      
      def nonce
        Time.now.to_i
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
end
