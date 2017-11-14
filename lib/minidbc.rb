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

  Cond = Struct.new( :blk, :location )

  def minidbc_call_wrap( method_name, new_method_name, check_pre, check_post, pre_check_invariants, post_check_invariants, *arg )
    minidbc_check_condition(minidbc_pre(method_name), *arg) if check_pre
    minidbc_check_condition(minidbc_invariants) if pre_check_invariants
    #TODO need to handle exception
    ret = send( new_method_name, *arg )
    minidbc_check_condition(minidbc_invariants) if post_check_invariants
    minidbc_check_condition(minidbc_post(method_name), ret, *arg) if check_post
    ret
  end

  def minidbc_pre(method_name)
    self.class.preconds[method_name] || []
  end

  def minidbc_post(method_name)
    self.class.postconds[method_name] || []
  end

  def minidbc_invariants
    self.class.invariants
  end

  module ClassMethods
    def preconds
      @minidbc_pres
    end

    def postconds
      @minidbc_posts
    end

    def invariants
      @invariants
    end

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


        @minidbc_pres[method_name] = @pres
        @minidbc_posts[method_name] = @posts

        @pres = []
        @posts = []

        #TODO need to support client code call alias_method
        alias_method new_method_name, method_name

        if method_name == :initialize
          @hook_initialize = true
          create_method_call_wrap( method_name, new_method_name, true, true, false, true )
        elsif private_methods.include? method_name
          create_method_call_wrap( method_name, new_method_name, true, true, false, false )
        else
          create_method_call_wrap( method_name, new_method_name, true, true, true, true )
        end
      end
    end

    def create_method_call_wrap( method_name, new_method_name, check_pre, check_post, pre_check_invariants, post_check_invariants )
      define_method method_name do |*arg|
        minidbc_call_wrap( method_name, new_method_name, check_pre, check_post, pre_check_invariants, post_check_invariants, *arg )
      end
    end

    def minidbc_init
      @pres = []
      @posts = []
      @minidbc_pres = {}
      @minidbc_posts = {}
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
