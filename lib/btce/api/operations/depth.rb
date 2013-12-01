module Btce
  class Depth < PublicOperation
    def initialize(pair)
      super 'depth', pair
    end
  end
end