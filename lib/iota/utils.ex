defmodule Iota.Utils do
	@moduledoc """
	This module provides various utility functions to handle IOTA's
	quirks.
	"""

	@tryte_symbols "9ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	@spec as_trinary(0..26) :: String.t
	defp as_trinary(n) do
		String.at(@tryte_symbols, n)
	end

	@spec as_tryte(integer) :: String.t
	defp as_tryte(n) do
		if n >= 27 do
			as_trinary(rem n, 27) <> as_tryte(div n, 27)
		else
			as_trinary n
		end
	end

	@doc """
	Returns a tryte-encoded version of string argument `str`. This will handle
	any kind of string with valid characters.
	"""
	@spec as_trytes(String.t) :: String.t
	def as_trytes(str) when is_bitstring(str) do
		Enum.reduce String.to_charlist(str), "", fn (c,s) -> s <> as_tryte(c) end
	end
end