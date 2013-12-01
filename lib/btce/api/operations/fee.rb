module Btce
  class Fee < PublicOperation
    def initialize(pair)
      super 'fee', pair
    end

    def trade
      json["trade"]
    end
  end
end