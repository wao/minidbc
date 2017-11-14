require "minidbc/version"

module Minidbc
  class DesignContractViolationException < Exception
  end

  def self.included(clz)
    clz.extend ClassMethods
    clz.minidbc_init
  end

  def minidbc_check_condition( condition_list, *args )
    condition_list.each do |cond| 
      if !instance_exec(*args, &cond.blk) 
        ( file, lineno ) = cond.location.split(":")
        puts "Contract Violation at #{cond.location}"
        if File.exist? file
          puts File.open(file).readlines[lineno.to_i - 1]
        end
        raise DesignContractViolationException.new( "Contact failed at #{cond.location}" )
      end
    end
  end

  def minidbc_private_call_wrap( new_method_name, pre_list, post_list, *arg)
    minidbc_check_condition(pre_list, *arg)
    ret = send( new_method_name, *arg )
    minidbc_check_condition(post_list, ret, *arg)
    ret
  end

  def minidbc_initialize_call_wrap( new_method_name, pre_list, post_list, invariants, *arg)
    ret = minidbc_private_call_wrap( new_method_name, pre_list, post_list, *arg)
    minidbc_check_condition(invariants)
    ret
  end

  def minidbc_call_wrap( new_method_name, pre_list, post_list, invariants, *args)
    minidbc_check_condition(invariants)
    #TODO need to handle exception
    minidbc_initialize_call_wrap( new_method_name, pre_list, post_list, invariants, *args )
  end

  Cond = Struct.new( :blk, :location )

  module ClassMethods
    def method_added(method_name)
      if /\w+_without_dbc/ =~ method_name.to_s
        return
      elsif  /(pre_|post_|check_minidbc_invariant)\w+/ =~ method_name.to_s
        return
      else

        new_method_name = :"#{method_name}_without_dbc"

        if instance_methods(false).include?(new_method_name)
          return
        end

        if method_name == :initialize && @hook_initialize
          return
        end


        pre_list = @pres
        post_list = @posts
        @pres = []
        @posts = []
        invariants = @invariants

        #TODO need to support client code call alias_method
        alias_method new_method_name, method_name

        if method_name == :initialize
          @hook_initialize = true
          create_initialize_call_wrap(method_name, new_method_name, pre_list, post_list, invariants)
        elsif private_methods.include? method_name
          create_private_method_call_wrap( method_name, new_method_name, pre_list, post_list )
        else
          create_method_call_wrap( method_name, new_method_name, pre_list, post_list, invariants )
        end
      end
    end

    def create_initialize_call_wrap(method_name, new_method_name, pre_list, post_list, invariants)
      define_method method_name do |*arg|
        minidbc_initialize_call_wrap( new_method_name, pre_list, post_list, invariants, *arg)
      end
    end

    def create_private_method_call_wrap( method_name, new_method_name, pre_list, post_list )
      define_method method_name do |*arg|
        minidbc_private_call_wrap( new_method_name, pre_list, post_list, *arg)
      end
    end

    def create_method_call_wrap( method_name, new_method_name, pre_list, post_list, invariants )
      define_method method_name do |*arg|
        minidbc_call_wrap( new_method_name, pre_list, post_list, invariants, *arg)
      end
    end

    def minidbc_init
      @pres = []
      @posts = []
      @invariants = []
      @hook_initialize = false

      #TODO need to check invariants on initialize
      # class << self
      # alias_method :minidbc_new, :new
      # def new(*arg)
      # ret = __new__(*arg)
      # ret.minidbc_check_condition(
      # end
      # end
    end


    def inherited(subclass)
      subclass.minidbc_init
    end

    def invariant(&blk)
      @invariants << Cond.new( blk, caller[0] )
    end

    def pre(&blk)
      @pres << Cond.new( blk, caller[0] )
    end

    def post(&blk)
      @posts << Cond.new( blk, caller[0] )
    end
  end
end
