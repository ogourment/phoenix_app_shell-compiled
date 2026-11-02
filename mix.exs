defmodule Mix.Tasks.Compile.BinaryPhoenixAppShell do
  use Mix.Task.Compiler
  @moduledoc false
  @root __DIR__
  @checksums %{
    "assets/js/journey.mjs" => "D13BA51D99B072A546B4B44AF16F7B0A527E36207A0853A565A65E2BDF6BDBE0",
    "ebin/Elixir.PhoenixAppShell.Components.beam" =>
      "327A76AAC1E16F4381D3DEBF1B35549D670A37AB59A153ABD49B07C67565FBB6",
    "ebin/Elixir.PhoenixAppShell.HostAdapter.beam" =>
      "CB082EFA4E6582530A7607AE7853BC0A1FE48FF28B52C54087B83DE4DD2391D2",
    "ebin/Elixir.PhoenixAppShell.Navigation.beam" =>
      "34B6EF7C1C7A34FE29B29D13656F2732D6780FEDA284315726839B5CA486E5F4",
    "ebin/Elixir.PhoenixAppShell.NavigationContributor.beam" =>
      "6A6B34CFA7B343841081392444B83EABAB41F44D0E9FE9F1781D693F263053C7",
    "ebin/phoenix_app_shell.app" =>
      "EA5B064B67C66F0A5975CAD2F3F6DEBE79EFE30CDF4F7B334E64F8630A565E21"
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
      version: "0.0.6",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_app_shell],
      deps: [phoenix_live_view: "~> 1.2.0"]
    ]
  end

  def application, do: [extra_applications: [:logger]]
end
