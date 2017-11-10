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

	@spec as_transaction(String.t) :: Iota.Transaction.t | {atom, String.t}
	def as_transaction(trytes) do
		if String.length(trytes) == @transaction_trytes_size do
			if String.match?(trytes, ~r/[9A-Z]{#{@transaction_trytes_size}}/) do
				%Iota.Transaction{
					signature: String.slice(trytes, 0..2186),
					address: String.slice(trytes, 2187..2267),
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