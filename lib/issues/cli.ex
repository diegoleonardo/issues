defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """
  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])

    case parse do
      {[help: true], _, _} -> :help
      {_, [user, project, count], _} -> {user, project, String.to_integer(count)}
      {_, [user, project], _} -> {user, project, @default_count}
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts("""
    usage:
    issues <user> <project> [ count | #{@default_count} ]
    """)

    System.halt(0)
  end

  def process({user, project, _count}) do
    user
    |> Issues.GithubIssues.fetch(project)
    |> decode_response
    |> convert_to_list_of_hashdicts
    |> sort_into_ascending_order
    |> Enum.take(1)
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort(
      list_of_issues,
      fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
    )
  end

  def parse_to_table(issues) when is_list(issues) do
    issues
    |> Enum.map(fn issue -> %{id: issue.id, title: issue.title, created_at: issue.created_at} end)
    |> Enum.map(fn issue -> "#{issue.id} | #{issue.title} | #{issue.created_at}" end)
    |> Enum.reduce(fn x, acc -> acc <> "\n" <> x end)
    |> write_table()
  end

  def write_table(body) do
    "\n#{header()}\n#{body}"
  end

  defp header do
    """
     #   | created_at           | title
     ----+----------------------+-----------------------------------------
    """
  end

  def decode_response({:ok, body}) do
    {_, body_list} = body
    body_list
  end

  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "message", 0)

    IO.puts("Error fetching from Github: #{message}")
    System.halt(2)
  end

  def convert_to_list_of_hashdicts(list) do
    list
    |> Enum.map(&Enum.into(&1, Map.new()))
  end
end
