# -*- coding: utf-8 -*-

# Copyright © 2013-2014, Christopher Mark Gore,
# Soli Deo Gloria,
# All rights reserved.
#
# 2317 South River Road, Saint Charles, Missouri 63303 USA.
# Web: http://cgore.com
# Email: cgore@cgore.com
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#   * Neither the name of Christopher Mark Gore nor the names of other
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
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

module Btce
  class API
    BTCE_DOMAIN = "btc-e.com"
    CURRENCY_PAIRS = %w(btc_eur
                        btc_rur
                        btc_usd
                        dsh_btc
                        eth_btc
                        eth_ltc
                        eth_rur
                        eth_usd
                        eur_rur
                        eur_usd
                        ltc_btc
                        ltc_eur
                        ltc_rur
                        ltc_usd
                        nmc_btc
                        nmc_usd
                        nvc_btc
                        nvc_usd
                        ppc_btc
                        ppc_usd
                        usd_rur)
    CURRENCIES = CURRENCY_PAIRS.map {|pair| pair.split("_")}.flatten.uniq.sort
    MAX_DIGITS = {
      'btc_eur' => 5,
      'btc_rur' => 5,
      'btc_usd' => 3,
      'dsh_btc' => 5,
      'eth_btc' => 5,
      'eth_ltc' => 5,
      'eth_rur' => 5,
      'eth_usd' => 5,
      'eur_rur' => 5,
      'eur_usd' => 5,
      'ltc_btc' => 5,
      'ltc_eur' => 3,
      'ltc_rur' => 5,
      'ltc_usd' => 6,
      'nmc_btc' => 5,
      'nmc_usd' => 3,
      'nvc_btc' => 5,
      'nvc_usd' => 3,
      'ppc_btc' => 5,
      'ppc_usd' => 3,
      'usd_rur' => 5
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
