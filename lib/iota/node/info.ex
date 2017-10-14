defmodule Iota.Node.Info do
	@moduledoc """
	Represents the info returned by the getNodeInfo API call
	"""

	@derive [Poison.Encoder]

	# NOTE: at this stage, poison doesn't support renaming fields so I have
	# to use CamelCase in the structure name.
	defstruct appName: "", appVersion: "", time: 0, neighbors: 0, tips: 0
	@type t() :: %Iota.Node.Info{appName: String.t, appVersion: String.t, time: integer, neighbors: integer, tips: integer}
end