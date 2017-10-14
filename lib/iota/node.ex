defmodule Iota.Node do
	use GenServer

	@moduledoc """
	Represents a process to interface with a IOTA node
	"""
	@default_iota_node "https://node.tangle.works:443"

	def start_link(options) do
		GenServer.start_link(__MODULE__, [options[:node_url] || @default_iota_node])
	end

	defp decode_node_info(%HTTPotion.Response{} = response) do
		case Poison.decode(response.body, as: %Iota.Node.Info{}) do
			{:ok, info} -> info
			error       -> error
		end
	end
	defp decode_node_info(_ = x) do
		{:error, x}
	end

	defp query_node(node_addr, command) do
		body = Poison.encode!(%{command: command}, [])

		HTTPotion.post(node_addr, [body: body, headers: ["Content-Type": "application/json"]])
	end

	@doc """
	Query the IOTA node information
	"""
	def handle_call(:node_info, _from, state) do
		[node_addr | _] = state
		info_or_err = node_addr
			|> query_node("getNodeInfo")
			|> decode_node_info
		{:reply, info_or_err, state}
	end
end