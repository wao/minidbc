require "test_helper"

class BaseClass
  include Minidbc

  def initialize(ac)
    @ac = ac
  end

  invariant{ @ac == 100 || @ac == 200 }

  pre{ |i| i = 1 || i == 2 }
  post{ |ret, i| i * 100 == ret }
  def a(i)
    @ac = i * 100
  end
end

class InheritTest < Minitest::Test
  context "Subclass" do
    should "check parent invariant for initialize" do
      class Sub < BaseClass
        def initialize(b)
          super(100)
          @ac = b
        end
      end

      assert_raises( Minidbc::DesignContractViolationException ){
        Sub.new(300)
      }
    end

    should "check posts of all ancesstor" do
      class Sub2 < BaseClass
        post{ |ret| ret == 200 }
        def a(i)
          @ac = i * 100
        end
      end

      assert_equal 200, Sub2.new(100).a(2)
      assert_equal 100, BaseClass.new(100).a(1)
      assert_raises( Minidbc::DesignContractViolationException ){
        Sub2.new(100).a(1)
      }
    end

    should "check latest pre and send warning( You should not redefine precondition )" do
      class Sub3 < BaseClass
        pre{ true }
        def a(i)
          @ac = 100
          i * 100
        end
      end

      assert_equal 500, Sub3.new(100).a(5)
    end
  end
end
