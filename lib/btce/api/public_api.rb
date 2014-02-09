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
  class PublicAPI < API
    OPERATIONS = %w(fee ticker trades depth)

    class << self
      def get_pair_operation_json(pair, operation, options={})
        list = pair.split('-')
        i = 0
        begin
          raise ArgumentError if not API::CURRENCY_PAIRS.include? list[i]
          i = i + 1
        end while i < list.length
        raise ArgumentError if not OPERATIONS.include? operation

        params = ""
        if options[:limit]
          if options[:limit].is_a? Integer
            if options[:limit] < 1
              raise ArgumentError, "Limit #{options[:limit]} < 1."
            else
              params = "?limit=#{options[:limit]}"
            end
          else
            raise ArgumentError,
              "Non-Integer limit #{options[:limit].inspect}."
          end
        end

        get_json url: "https://#{API::BTCE_DOMAIN}/api/3/#{operation}/#{pair}#{params}"
      end

      OPERATIONS.each do |operation|
        class_eval %{
          def get_pair_#{operation}_json(pair, options={})
            get_pair_operation_json pair, "#{operation}", options
          end
        }

        API::CURRENCY_PAIRS.each do |pair|
          class_eval %{
            def get_#{pair}_#{operation}_json(options={})
              get_pair_#{operation}_json "#{pair}", options
            end
          }
        end
      end
    end
  end
end
