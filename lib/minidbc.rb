require "minidbc/version"

module Minidbc
  class DesignContractViolationException < Exception
  end

  Config = { mode: :debug }

  def self.included(clz)
    if !const_defined?(:ClassMethods)
      case Config[:mode]
      when :debug
        require "minidbc/debug_mode"
      else
        require "minidbc/release_mode"
      end
    end

    clz.extend ClassMethods
    clz.minidbc_init if Config[:mode] == :debug
  end

end
