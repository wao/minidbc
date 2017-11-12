require "test_helper"

class MinidbcTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Minidbc::VERSION
  end

  context "pre()" do
    setup do
      class T
        include Minidbc
      end
    end

    should "remain silent if pre block return true" do
      class T
        pre{ true }
        def a
          1
        end
      end

      assert_equal 1, T.new.a
    end

    should "raise exception DesignContractViolation if pre() block return failed" do
      class T
        pre{ false }
        def b
        end
      end

      assert_raises( Minidbc::DesignContractViolationException ){
        T.new.b
      }
    end

    should "support multiple pre conditions" do
      class T
        def ra
          @a
        end

        def initialize
          @a = 0
        end

        pre{ @a += 1
        @a == 1 }
        pre{ @a += 1
        @a == 2 }
        def c
          1
        end
      end

      a = T.new
      assert_equal 0, a.ra
      assert_equal 1, a.c
      assert_equal 2, a.ra
    end

    should "able to get args of method" do
      class T
        pre{ |pa| pa == 1 }
        def d(p)
          p
        end
      end

      assert_equal 1, T.new.d(1)
      assert_raises(Minidbc::DesignContractViolationException) do
        T.new.d(2)
      end
    end
  end

  context "post()" do
    setup do
      class TP
        include Minidbc
      end
    end

    should "remain silent if post block return true" do
      class TP
        post{ true }
        def a
          1
        end
      end

      assert_equal 1, TP.new.a
    end

    should "raise exception DesignContractViolation if post() block return failed" do
      class TP
        post{ false }
        def b
        end
      end

      assert_raises( Minidbc::DesignContractViolationException ){
        TP.new.b
      }
    end

    should "support multiple post conditions" do
      class TP
        def ra
          @a
        end

        def initialize
          @a = 0
        end

        post{ @a += 1
        @a == 5 }
        post{ @a += 1
        @a == 6 }
        def c
          @a = 4
          1
        end
      end

      a = TP.new
      assert_equal 0, a.ra
      assert_equal 1, a.c
      assert_equal 6, a.ra
    end

    should "able to get ret and args of method" do
      class TP
        post{ |ret, pa| ret == pa }
        post{ |ret, pa| pa == 1 }
        def d(p)
          p
        end
      end

      assert_equal 1, TP.new.d(1)
      assert_raises(Minidbc::DesignContractViolationException) do
        TP.new.d(2)
      end
    end
  end

  context "invariant" do
    setup do
      class TI
        include Minidbc
        invariant { @a == 1 }
      end
    end

    should "check before each public method" do
      class TI
        def a
          @a
        end
      end

      assert_raises(Minidbc::DesignContractViolationException){
        TI.new.a
      }
    end

    should "check after each public method" do
      class TII
        include Minidbc
        invariant { @a == 1 }

        def initialize
          @a = 1
        end

        def aa
          @a
        end

        def b
          @a = 2
        end
      end

      assert_equal 1, TII.new.aa
      assert_raises(Minidbc::DesignContractViolationException){
        d = TII.new
        d.b
      }
    end

    should "not check before and after each public method" do
      class TII
        def cp
          @a = 7
          ret = p
          @a = 1
          ret
        end

        private def p
          @a = 13
          @a
        end
      end

      assert_equal 13, TII.new.cp
    end
  end

end
