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

	defp decode_tips(%HTTPotion.Response{} = response) do
		case Poison.decode(response.body, as: %{"hashes" => [String]}) do
			{:ok, tips} -> tips["hashes"]
			error       -> error
		end
	end
	defp decode_tips(_ = x) do
		{:error, x}
	end

	defp decode_trytes(%HTTPotion.Response{} = response) do
	case Poison.decode(response.body, as: %{"trytes" => [String]}) do
			{:ok, trytes} -> trytes["trytes"]
			error         -> error
		end
	end
	defp decode_trytes(_ = x) do
		{:error, x}
	end

	defp query_node(node_addr, command, params \\ %{}) do
		body = Poison.encode!(Map.put(params, :command, command), [])

		HTTPotion.post(node_addr, [body: body, timeout: 30000, headers: ["Content-Type": "application/json"]])
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
	@doc """
	Query the IOTA node for its list of tips
	"""
	def handle_call(:tips, _from, state) do
		[node_addr | _] = state
		tips_or_err = node_addr
			|> query_node("getTips")
			|> decode_tips
		{:reply, tips_or_err, state}
	end

	@doc """
	Query the IOTA node for the trytes associated with the transaction hashes
	passed as an argument. Example:

		GenServer.call(node_pid, {:trytes, ["RGCOQVMOACOZJMEQUIUP9TEITW9KWTWILKDRXTFVKXBIJTNCQXJXTGAVITPWZO9QLHWYBERNMLHHZ9999"]})
	"""
	def handle_call({:trytes, hashes}, _from, state) when is_list(hashes) do
		[node_addr | _] = state
		trytes_or_err = node_addr
			|> query_node("getTrytes", %{"hashes" => hashes})
			|> decode_trytes
		{:reply, trytes_or_err, state}
	end
end