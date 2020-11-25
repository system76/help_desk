defmodule HelpDesk.Zendesk do
  def get(path) do
    :get
    |> Finch.build(complete_url(path), zendesk_headers())
    |> finch_request()
  end

  def post(path, data) do
    json = Jason.encode!(data)

    :post
    |> Finch.build(complete_url(path), zendesk_headers(), json)
    |> finch_request()
  end

  def put(path, data) do
    json = Jason.encode!(data)

    :put
    |> Finch.build(complete_url(path), zendesk_headers(), json)
    |> finch_request()
  end

  defp finch_request(req) do
    with {:ok, %{body: body} = response} <- Finch.request(req, Sparrow) do
      {:ok, %{response | body: Jason.decode!(body)}}
    end
  end

  defp zendesk_headers do
    [
      {"Authorization", "Basic " <> authorization()},
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]
  end

  defp authorization do
    email = Application.get_env(:zen_ex, :user)
    token = Application.get_env(:zen_ex, :api_token)

    Base.encode64("#{email}/token:#{token}", case: :lower)
  end

  defp complete_url(path) do
    domain = Application.get_env(:ex_env, :subdomain)
    Path.join(domain, path)
  end
end
