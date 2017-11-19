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

	test "can turn an integer into a list of trits" do
		out = Iota.Utils.as_trits(0)
		assert length(out) == 1
		assert hd(out) == 0

		out = Iota.Utils.as_trits(1)
		assert length(out) == 1
		assert hd(out) == 1

		out = Iota.Utils.as_trits(2)
		assert length(out) == 2
		assert hd(out) == -1

		out = Iota.Utils.as_trits(-1)
		assert length(out) == 1
		assert hd(out) == -1

		out = Iota.Utils.as_trits(-2)
		assert length(out) == 2
		assert hd(out) == 1

		out = Iota.Utils.as_trits(-10)
		assert length(out) == 3
		[a, b, c] = out
		assert a == -1
		assert b == 0
		assert c == -1

		out = Iota.Utils.as_trits(8)
		assert length(out) == 3
		[a, b, c] = out
		assert a == -1
		assert b == 0
		assert c == 1
	end

	test "always return a list of numbers in -1..1" do
		for i <- -1000..1000 do
			out = Iota.Utils.as_trits(i)
			for t <- out do
				assert (t >= -1 && t <= 1)
			end
		end
	end

	test "string to trits conversion rejects a string with an odd length" do
		assert {:error, _} = Iota.Utils.as_trits("A")
	end

	test "string to trits conversion rejects non-tryte-encoded string" do
		assert {:error, _} = Iota.Utils.as_trits("$%")
	end

	test "string to trits conversion returns a list with a length multiple of 3" do
		for n <- 1..1000 do
			out = Iota.Utils.as_trits String.duplicate("A", n*2)
			assert rem(length(out),3) == 0
		end
	end

	test "string to integer conversion of 9 returns 0" do
		assert 0 = Iota.Utils.trytes_to_int("9")
	end

	test "string to integer conversion of M returns 13" do
		assert 13 = Iota.Utils.trytes_to_int("M")
	end

	test "string to integer conversion of AB returns 55" do
		assert 55 = Iota.Utils.trytes_to_int("AB")
	end

	test "string to integer conversion of an invalid string returns an error" do
		assert {:error, _} = Iota.Utils.trytes_to_int("hello?")
	end
end