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

require 'spec_helper'

require 'btce'
include Btce

describe String do
  describe :camelcase_to_snakecase do
    it "correctly handles capitalization at the front" do
      "Test".camelcase_to_snakecase
        .should == "test"
    end

    it "correctly handles capitalization in the middle" do
      "thisIsATest".camelcase_to_snakecase
        .should == "this_is_a_test"
    end
  end

  describe :valid_json? do
    it "returns true if it is valid json" do
      "[1,2,3]".should be_valid_json
    end

    it "returns false if it is invalid json" do
      "blarg".should_not be_valid_json
    end
  end
end

describe API do
  describe :KEY do
    it "contains the key entry" do
      API::KEY['key'].should be_a String
    end

    it "contains the secret entry" do
      API::KEY['secret'].should be_a String
    end
  end

  describe :get_https

  describe :get_json
end

describe PublicAPI do
  describe :get_pair_operation_json
end

describe PublicOperation do
  before :all do
    @op = PublicOperation.new "ticker", "btc_usd"
  end

  describe :new do
    it "sets the operation" do
      @op.operation
        .should == "ticker"
    end

    it "sets the pair" do
      @op.pair
        .should == "btc_usd"
    end

    it "loads the json" do
      @op.json
        .should_not be_nil
    end
  end
end

describe Fee do
  before :all do
    @fee = Fee.new "btc_usd"
  end

  describe :new do
    it "sets the operation to the default 'fee'" do
      @fee.operation
        .should == "fee"
    end

    it "sets the pair" do
      @fee.pair
        .should == "btc_usd"
    end

    it "loads the json" do
      @fee.json
        .should_not be_nil
    end    
  end

  describe :trade do
    it "returns the fee for a trade" do
      @fee.trade
        .should be_a Float
    end
  end
end

describe TradeAPI do
  describe :sign

  describe :trade_api_call

  describe :nonce
end
