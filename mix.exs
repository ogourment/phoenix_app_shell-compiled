defmodule Mix.Tasks.Compile.BinaryPhoenixAppShell do
  use Mix.Task.Compiler
  @moduledoc false
  @root __DIR__
  @checksums %{
    "assets/css/connection.css" =>
      "8E550EB90D5D99EA1A609FF37DED257C78D2000ACE13FEABA18B41A7D6A2B1CB",
    "assets/js/journey.mjs" => "D13BA51D99B072A546B4B44AF16F7B0A527E36207A0853A565A65E2BDF6BDBE0",
    "ebin/Elixir.PhoenixAppShell.Collection.beam" =>
      "276456E1DCA8357F7FD54008A43444EF63CAD97B25C1F668E2818E84E3F07717",
    "ebin/Elixir.PhoenixAppShell.Components.beam" =>
      "16FBFA14E8C7F697D80C0F488E04DDB444F41C497EDC4343A55E927068F7F06F",
    "ebin/Elixir.PhoenixAppShell.Connection.beam" =>
      "499A6997D86A9D12F67D75841168338DC21E540EC77A96B0A541908F13EFF864",
    "ebin/Elixir.PhoenixAppShell.HostAdapter.beam" =>
      "CB082EFA4E6582530A7607AE7853BC0A1FE48FF28B52C54087B83DE4DD2391D2",
    "ebin/Elixir.PhoenixAppShell.Navigation.beam" =>
      "144033436C37D6D5276DA2F610161AEA6FB2D8CEF21C5FEE4408CE4CEA59D1AE",
    "ebin/Elixir.PhoenixAppShell.NavigationContributor.beam" =>
      "6A6B34CFA7B343841081392444B83EABAB41F44D0E9FE9F1781D693F263053C7",
    "ebin/Elixir.PhoenixAppShell.Selection.beam" =>
      "E1B2F7456A4C7BB1A3406C3665E2EDC4D1EDADBCAE5C60C7DB7404E88925CCB9",
    "ebin/phoenix_app_shell.app" =>
      "6B8EE70E184981F137C150746E49942B8BFA15F6B63A0D8DF98A9C4E6E8A763D"
  }

  @impl true
  def run(_args) do
    series = Version.parse!(System.version()) |> Map.take([:major, :minor])

    unless series == %{major: 1, minor: 20} and System.otp_release() == "29" do
      Mix.raise("phoenix_app_shell requires a binary distribution for Elixir 1.20.x / OTP 29")
    end

    for {path, expected} <- @checksums do
      bytes = File.read!(Path.join(@root, path))

      unless Base.encode16(:crypto.hash(:sha256, bytes)) == expected do
        Mix.raise("phoenix_app_shell artifact checksum mismatch: #{path}")
      end

      if String.starts_with?(path, "ebin/") do
        target = Path.join(Mix.Project.compile_path(), Path.basename(path))
        File.mkdir_p!(Path.dirname(target))
        File.write!(target, bytes)
      end
    end

    {:ok, []}
  end
end

defmodule Compiled.PhoenixAppShell.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_app_shell,
      version: "0.1.0",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_app_shell],
      deps: [phoenix_live_view: "~> 1.2.0"]
    ]
  end

  def application, do: [extra_applications: [:logger]]
end
