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
                    WithdrawCoin
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
