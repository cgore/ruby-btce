module Btce
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
end