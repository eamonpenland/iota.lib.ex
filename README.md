# iota.lib.ex

An Elixir wrapper around the IOTA node API.

## Installation

In your `mix.exs`, add the following line:

```elixir
def application do
  [applications: [..., :iota_lib]]
end

...

defp deps do
  ...
  {:iota_lib, github: "peaqio/iota.lib.ex"}
end
```

This library will be released on hex.pm when it covers all basic functions.

## Configuration

In your `config/config.exs` or any other environment-specific files it includes, set:

```elixir
config :iota_lib, :node_addr, http://example.com:14265
```

## Documentation

When all functions will have been ported, documentation will be available on hexducs.pm. In the mean time, 
here's a short summary:

The `Iota.Node` process accepts calls corresponding to the API, using snake case and removing the `get` prefix when
present. This is because the API actually uses the `POST` HTTP word and the `get` prefix makes it confusing. So, for
instance, `getInclusionStates` becomes `:inclusion_states`.

    iex(1)> {:ok, pid} = Iota.Node.start_link()
    {:ok, #PID<0.213.0>}
    iex(2)> info = GenServer.call(pid, :node_info)
    %Iota.Node.Info{appName: "IRI", appVersion: "1.4.1",
      latestMilestone: "DDPASKGNBAGUVQWSDKOBVTAVNLGWQTCVVHVTYPJDQQZHCDRZYMKRLEDYJUXJZHWGAAQEXFSPLUOQ99999",
      latestMilestoneIndex: 257455,
      latestSolidSubtangleMilestone: "DDPASKGNBAGUVQWSDKOBVTAVNLGWQTCVVHVTYPJDQQZHCDRZYMKRLEDYJUXJZHWGAAQEXFSPLUOQ99999",
      latestSolidSubtangleMilestoneIndex: 257455, neighbors: 4, time: 1509196327069,
      tips: 4165}

## Running tests

    $ mix test

## Contributing

We welcome PRs, or simply open an issue!

## TODO

  - [ ] Finish low-level API
  - [ ] Implement `iota.api`
