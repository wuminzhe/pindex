class Network
  attr_reader :name, :rpc, :chain_id, :max_scan_range

  def initialize(name, chain_id, rpc, max_scan_range = nil)
    @name = name.to_s
    @chain_id = chain_id
    @rpc = rpc
    @max_scan_range = max_scan_range || 20_000
  end

  def contracts
    Contract.all.select { |contract| contract.network.name.downcase == name.downcase }
  end

  def start_block
    result = -1
    contracts.each do |contract|
      contract.start_block
      result = contract.start_block if result == -1 || contract.start_block < result
    end
    result
  end

  class << self
    def all
      @all ||= _all
    end

    def find(name)
      all.find { |network| network.name.downcase == name.downcase }
    end

    def _all
      Rails.application.config.pug['networks'].map do |name, network|
        Network.new(
          name,
          network[:chain_id],
          network[:rpc],
          network[:max_scan_range]
        )
      end
    end
  end
end