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
		assert String.length(out) == 6
		assert out == "QHYEKF"

		# Test non-printable characters
		out = Iota.Utils.as_trytes(<<1,127>>)
		assert String.length(out) == 4
		assert out == "A9SD"
	end

	test "non-zero length output string of as_trytes is non-zero length" do
		out = Iota.Utils.as_trytes("hello")
		assert String.length(out) > 0
	end

	test "zero-length output string of as_trytes is zero length" do
		out = Iota.Utils.as_trytes("")
		assert String.length(out) == 0
	end

	test "output of to_trytes is 2 chars-aligned" do
		assert String.length(Iota.Utils.as_trytes(<<1>>)) == 2
	end

	test "invalid size for a tryte string is rejected" do
		assert {:error, _} = Iota.Utils.as_string("A")
	end

	test "zero-length tryte string returns a zero-length string" do
		assert "" == Iota.Utils.as_string("")
	end

	test "invalid character in a tryte string causes an error" do
		assert {:error, _} = Iota.Utils.as_string(":A")
	end

	test "can decode tryte strings containing various chars" do
		out = Iota.Utils.as_string(Iota.Utils.as_trytes("abc"))
		assert out == "abc"

		out = Iota.Utils.as_string(Iota.Utils.as_trytes("頭"))
		assert out == "頭"

		assert Iota.Utils.as_string("A9") == <<1>>
		assert Iota.Utils.as_string(Iota.Utils.as_trytes(<<1,127>>))
	end
end