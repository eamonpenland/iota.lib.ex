defmodule Iota.Transaction do
    @moduledoc """
    Represents an IOTA transaction
    """

    @digits_per_address     81
    @digits_per_bundle      81
    @digits_per_nonce       27
    @digits_per_signature   2187
    @digits_per_tag         27

    defstruct address:            String.duplicate("9", @digits_per_address),
                bundle:           String.duplicate("9", @digits_per_bundle),
                nonce:            String.duplicate("9", @digits_per_nonce),
                signature:        String.duplicate("9", @digits_per_signature),
                trunk:            String.duplicate("9", @digits_per_address),
                branch:           String.duplicate("9", @digits_per_address),
                tag:              String.duplicate("9", @digits_per_tag),
                weight_magnitude: 0,
                value:            0
    @type t() :: %Iota.Transaction{address: String.t, bundle: String.t, nonce: String.t, signature: String.t, tag: String.t, branch: String.t, trunk: String.t, weight_magnitude: integer, value: integer}
end