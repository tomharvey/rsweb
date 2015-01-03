# == Setup some basic logging
#
# Can be used in any class
#
module Logging
  def logger
    Logging.logger
  end

  def self.logger
    @logger ||= Logger.new('rsweb.log')
  end
end