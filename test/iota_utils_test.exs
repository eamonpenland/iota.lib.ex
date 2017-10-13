defmodule Iota.Utils.Test do
	use ExUnit.Case
	doctest Iota.Utils

	test "output string of as_trytes only contains valid characters" do
		# Test regular ascii
		out = Iota.Utils.as_trytes("abc")
		assert String.length(out) == 6
		assert out == "PCQCRC"

		# Test unicode
		out = Iota.Utils.as_trytes("頭")
		assert String.length(out) == 4
		assert out == "WKZA"

		# Test non-printable characters
		out = Iota.Utils.as_trytes(<<1,127>>)
		assert String.length(out) == 3
		assert out == "ASD"
	end

	test "non-zero length output string of as_trytes is non-zero length" do
		out = Iota.Utils.as_trytes("hello")
		assert String.length(out) > 0
	end

	test "zero-length output string of as_trytes is zero length" do
		out = Iota.Utils.as_trytes("")
		assert String.length(out) == 0
	end
end