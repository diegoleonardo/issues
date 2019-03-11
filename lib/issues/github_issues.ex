defmodule Issues.GithubIssues do
  @user_agent [{"User-agent", "Elixir diego@santos.com"}]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    user
    |> issues_url(project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({:ok, %{status_code: 200, body: body}}), do: {:ok, Poison.decode(body)}

  def handle_response({:ok, %{status_code: _, body: body}}), do: {:error, Poison.decode(body)}
end
