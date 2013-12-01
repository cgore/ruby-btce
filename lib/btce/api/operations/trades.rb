module Btce
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
end