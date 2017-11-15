require "test_helper"

Minidbc::Config[:mode] = :release

class Release
  include Minidbc

  invariant{ @a == 100 }

  pre{ |a| a == 30 }
  def initialize(a = 10)
    @a = a
  end

  def a
    @a
  end
end

class Sample
  def initialize(a = 10)
    @a = a
  end

  def a
    @a
  end
end

class ReleaseTest < Minitest::Test
  context "Minidbc Release Mode" do
    should "not check condition at all" do
      assert_equal 9, Release.new(9).a
    end

    should "not introduce any extra method such as minidbc_..., ..._without_dbc" do
      assert_equal Sample.instance_methods.sort, Release.instance_methods.sort      
      assert_equal [ :pre, :post, :invariant ], Release.methods - Sample.methods.sort
    end
  end
end
