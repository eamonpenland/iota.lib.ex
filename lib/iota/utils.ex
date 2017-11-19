defmodule Iota.Utils do
	@moduledoc """
	This module provides various utility functions to handle IOTA's
	quirks.
	"""

	@tryte_symbols "9ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	@tryte_encoding_error		"Invalid character in tryte-encoded string"
	@invalid_string_error		"Invalid string"
	@invalid_tryte_length_error "Invalid tryte length"

	@transaction_trytes_size    2673

	@tryte_to_trits {
		[ 1,  0,  0],
		[-1,  1,  0],
		[ 0,  1,  0],
		[ 1,  1,  0],
		[-1, -1,  1],
		[ 0, -1,  1],
		[ 1, -1,  1],
		[-1,  0,  1],
		[ 0,  0,  1],
		[ 1,  0,  1],
		[-1,  1,  1],
		[ 0,  1,  1],
		[ 1,  1,  1],
		[-1, -1, -1],
		[ 0, -1, -1],
		[ 1, -1, -1],
		[-1,  0, -1],
		[ 0,  0, -1],
		[ 1,  0, -1],
		[-1,  1, -1],
		[ 0,  1, -1],
		[ 1,  1, -1],
		[-1, -1,  0],
		[ 0, -1,  0],
		[ 1, -1,  0],
		[-1,  0,  0]
	}

	defp nibble_to_trits(57), do: [0,0,0]
	defp nibble_to_trits(nibble) when nibble in 65..90, do: elem(@tryte_to_trits, nibble-65)
	defp nibble_to_trits(_), do: {:error, @tryte_encoding_error}

	defp nibble_to_integer(57), do: 0
	defp nibble_to_integer(nibble) when nibble in 65..90, do: nibble - 65 + 1
	defp nibble_to_integer(_), do: {:error, @tryte_encoding_error}

	@spec as_trinary(0..26) :: String.t
	defp as_trinary(n) do
		String.at(@tryte_symbols, n)
	end

	@spec byte_as_tryte(0..255) :: String.t
	defp byte_as_tryte(n) when n in 0..255 do
		as_trinary(rem n, 27) <> as_trinary(div n, 27)
		end

	@doc """
	Returns a tryte-encoded version of string argument `str`. This will handle
	any kind of string with valid characters.
	"""
	@spec as_trytes(String.t) :: String.t
	def as_trytes(str) when is_bitstring(str) do
		byte_list = for <<c::8 <- str>>, do: c
		Enum.reduce byte_list, "", fn (c,s) -> s <> byte_as_tryte(c) end
	end

	@doc """
	Converts a string containing the heptavigesimal representation
	of a tryte-encoded number into an integer.

	    > Iota.Utils.trytes_to_int("9SISTERS")
		205803034065

	"""
	@spec trytes_to_int(String.t) :: integer | {atom, String.t}
	def trytes_to_int(str) do
		if str =~ ~r/^[9A-Z]+$/ do
			# "Big Endian" Heptavigesimal
			beh = Enum.reverse to_charlist str

			Enum.reduce beh, 0, fn (hep_vig, total) ->
				trigit = case hep_vig do
					x when x in 65..90 -> hep_vig-64
					_                     -> 0
				end
				total * 27 + trigit
			end
		else
			{:error, @tryte_encoding_error}
		end
	end

	defp as_binary(<<>>), do: <<>>
	defp as_binary(trytes) do
		<<l, h, rest::binary>> = trytes
		<<nibble_to_integer(l) + 27 * nibble_to_integer(h)>> <> as_binary(rest)
	end

	@spec as_string(String.t) :: String.t
	def as_string(trytes) do
		if rem(String.length(trytes), 2) != 0 do
			{:error, @invalid_tryte_length_error}
		else
			if trytes =~ ~r{^[A-Z9]*$} do
				b = as_binary trytes
				if String.valid?(b), do: b, else: {:error, @invalid_string_error}
			else
				{:error, @tryte_encoding_error}
			end
		end
	end

	defp as_trits_helper(0, _), do: [0]
	defp as_trits_helper(i, s) when is_integer(i) do
		d = div(i,3)
		r = rem(i,3)
		{t, x} = if r == 2, do: {-1, d+1}, else: {r,d}
		if x != 0, do: [t * s] ++ as_trits_helper(x, s), else: [t*s]
	end

	@doc """
	Turns an integer into a list of trits.

	    > Iota.Utils.as_trits(8)
		[-1, 0, 1]

	"""
	@spec as_trits(integer) :: [-1..1]
	def as_trits(num) when is_integer(num) do
		sign = if num > 0, do: 1, else: -1
		abs_num = abs(num)
		as_trits_helper(abs_num, sign)
	end

	@doc """
	Turns a tryte-encoded string into a list of trits. The string length
	has to be a multiple of 2.

	    > Iota.Utils.as_trits("CLOUD9")
		[]
	
	"""
	@spec as_trits(String.t) :: [-1..1] | {atom, String.t}
	def as_trits(str) do
		if rem(String.length(str),2) == 0 do
			if str =~ ~r/^[9A-Z]+$/ do
				Enum.flat_map to_charlist(str), fn c -> nibble_to_trits c end
			else
				{:error, @tryte_encoding_error}
			end
		else
			{:error, "Invalid string length (must be a multiple of 2)"}
		end
	end

	@doc """
	Transforms a string of trytes returned by `:trytes` into a `Transaction` structure.

	    > Iota.Utils.as_transaction("AHEAJD...")
		%Iota.Transaction{...}

	"""
	@spec as_transaction(String.t) :: Iota.Transaction.t | {atom, String.t}
	def as_transaction(trytes) do
		if String.length(trytes) == @transaction_trytes_size do
			if String.match?(trytes, ~r/[9A-Z]{#{@transaction_trytes_size}}/) do
				%Iota.Transaction{
					signature: String.slice(trytes, 0..2186),
					address: String.slice(trytes, 2187..2267),
					value: trytes_to_int(String.slice(trytes, 2268..2294)),
					bundle: String.slice(trytes, -324..-244),
					trunk: String.slice(trytes, -243..-163),
					branch: String.slice(trytes, -162..-82),
					tag: String.slice(trytes, -81..-66),
					nonce: String.slice(trytes, -27..-1)
				}
			else
				{:error, "Not a trytes string"}
			end
		else
			{:error, "Invalid transaction trytes length"}
		end
	end
end