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
require 'net/http'
require 'net/https'
require 'uri'

module Btce
  class API
    BTCE_DOMAIN = "btc-e.com"
    CURRENCIES =  %w(btc usd rur ltc nmc eur nvc)
    CURRENCY_PAIRS = %w(btc_usd btc_rur ltc_btc ltc_usd ltc_rur nmc_btc usd_rur eur_usd nvc_btc)
    MAX_DIGITS = {
      "btc_usd" => 3,
      "btc_rur" => 4,
      "ltc_btc" => 5, 
      "ltc_usd" => 6,
      "ltc_rur" => 4,
      "nmc_btc" => 4,
      "usd_rur" => 4,
      "eur_usd" => 4, 
      "nvc_btc" => 4
    }

    class << self
      def get_https(url)
        raise ArgumentError if not url.is_a? String
        uri = URI.parse url
        http = Net::HTTP.new uri.host, uri.port
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new uri.request_uri
        response = http.request request
        response.body
      end

      def get_json(url)
        JSON.load get_https url
      end
    end
  end

  class PublicAPI < API
    OPERATIONS = %w(fee ticker trades depth)

    class << self
      OPERATIONS.each do |operation|
        class_eval %{
          def get_pair_#{operation}_json(pair)
            raise ArgumentError if not API::CURRENCY_PAIRS.include? pair
            get_json "https://\#{API::BTCE_DOMAIN}/api/2/\#{pair}/#{operation}"
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

  class TradeAPI < API
  end
end
