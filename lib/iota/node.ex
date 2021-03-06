defmodule Iota.Node do
	use GenServer

	@moduledoc """
	Represents a process to interface with a IOTA node.

	Sample configuration:

	config :iota_lib, :node_addr, "http://localhost:14265"

	Sample use:
	
		{:ok, pid} = Iota.Node.start_link()
		info = GenServer.call(pid, :node_info)
		IO.puts info.latestMilestone
	"""
	@default_iota_node "http://devnode.peaq.io:14600"
	@iota_api_version  "1.4.1.1"

	def start_link(options \\ []) do
		GenServer.start_link(__MODULE__, [Application.get_env(:iota_lib, :node_addr) || @default_iota_node] ++ options)
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

	defp decode_tta(%HTTPotion.Response{} = response) do
		case Poison.decode(response.body) do
			{:ok, tta} -> {tta["trunkTransaction"], tta["branchTransaction"]}
			error       -> error
		end
	end
	defp decode_tta(_ = x) do
		{:error, x}
	end

	defp decode_is(%HTTPotion.Response{} = response) do
		case Poison.decode(response.body) do
			{:ok, is} -> is["states"]
			error     -> error
		end
	end
	defp decode_is(_ = x) do
		{:error, x}
	end

	defp decode_balances(%HTTPotion.Response{} = response) do
		case Poison.decode(response.body) do
			{:ok, b} -> Map.delete(b, "duration")
			error    -> error
		end
	end
	defp decode_balances(_ = x) do
		{:error, x}
	end

	defp query_node(node_addr, command, params \\ %{}) do
		body = Poison.encode!(Map.put(params, :command, command), [])

		HTTPotion.post(node_addr, [body: body, timeout: 30000, headers: ["Content-Type": "application/json", "X-IOTA-API-Version": @iota_api_version]])
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

	@doc """
	Query the IOTA node for a trunk and branch transaction.
	Example:

		{trunk, branch} = GenServer.call(node_pid, {:transactions_to_approve, 27}, :infinity)
	
	`:infinity` is here because the query take more time than the default 5s given by GenServer.
	"""
	def handle_call({:transactions_to_approve, depth}, _from, state) when is_integer(depth) do
		[node_addr | _] = state
		tta_or_err = node_addr
			|> query_node("getTransactionsToApprove", %{"depth" => depth})
			|> decode_tta
		{:reply, tta_or_err, state}
	end

	@doc """
	Query the IOTA node for the inclusion state of passed transactions
	Example:

		[first|_] = GenServer.call(node_pid, {:inclusion_states, transactions, tips})
	"""
	def handle_call({:inclusion_states, transactions, tips}, _from, state) when is_list(transactions) and is_list(tips) do
		[node_addr | _] = state
		is_or_err = node_addr
			|> query_node("getInclusionStates", %{"transactions" => transactions, "tips" => tips})
			|> decode_is
		{:reply, is_or_err, state}
	end

	@doc """
	Query the IOTA node for the balance of an array of addresses passed as argument
	Example:

		GenServer.call(node_pid, {:balances, ["FFUIAREGAAAHNTPJRGRFCNCNOTKTKPWJEGUDWQHZVVO9MTAXZIDMXBMWJXTLUBHNFNKYCCTQUXOUYFKX9"]})

	Returns a map containing the balances in an array accessible through the `balances`
	key. The order of balances is the  same as that of the `addresses` parameter array.
	The map also contains a `milestone` and `milestoneIndex` field.
	In the documentation, the threshold is required to be 100, so it is not passed as
	an argument in that call.
	"""
	def handle_call({:balances, addresses}, _from, state) when is_list(addresses) do
		[node_addr | _] = state
		balances_or_err = node_addr
			|> query_node("getBalances", %{"addresses" => addresses, "threshold" => 100})
			|> decode_balances
		{:reply, balances_or_err, state}
	end

end