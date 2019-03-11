defmodule CliTest do
  use ExUnit.Case

  import Issues.CLI,
    only: [
      parse_args: 1,
      sort_into_ascending_order: 1,
      convert_to_list_of_hashdicts: 1,
      parse_to_table: 1
    ]

  defp fake_created_at_list(values) do
    data =
      for value <- values,
          do: [{"created_at", value}, {"other_data", "xxx"}]

    convert_to_list_of_hashdicts(data)
  end

  defp fake_github_json_list() do
    [
      %{id: 1, title: "issue 1", created_at: "2019-03-10", reason: "reason 1", user: "user 1"},
      %{id: 2, title: "issue 2", created_at: "2019-03-10", reason: "reason 2", user: "user 2"},
      %{id: 3, title: "issue 3", created_at: "2019-03-10", reason: "reason 3", user: "user 3"},
      %{id: 4, title: "issue 4", created_at: "2019-03-10", reason: "reason 4", user: "user 4"}
    ]
  end

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "three values returned if three given" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "count is defaulted if two values given" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end

  test "sort asceding orders the correct way" do
    result = fake_created_at_list(["c", "a", "b"]) |> sort_into_ascending_order()

    issues = for issue <- result, do: issue["created_at"]

    assert issues == ~w{a b c}
  end

  test "id, title and created_at returned in execute process" do
    result = fake_github_json_list() |> parse_to_table
    expected_value = "\n #   | created_at           | title
 ----+----------------------+-----------------------------------------

1 | issue 1 | 2019-03-10
2 | issue 2 | 2019-03-10
3 | issue 3 | 2019-03-10
4 | issue 4 | 2019-03-10"
    assert expected_value == result
  end
end
