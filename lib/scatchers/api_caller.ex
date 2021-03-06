defmodule Scatchers.APICaller do

  def pull_search_result do
    # IO.puts "#{DateTime.utc_now()} :: API call start"
    # url = "https://www.mercari.com/jp/search/?keyword=%E3%83%99%E3%82%A2%E3%83%96%E3%83%AA%E3%83%83%E3%82%AF"
    url = "https://us.hideproxy.me/go.php?u=3WXBF5FaZtvzHUAEjnPcDzjHXH5xU2zGCIJqVVoHVEtUn5SOlYyJMRgB2G6%2FxzJXdt7xaqSXIoivixK1YM2vGoJQMTS4lwp%2FbkczBZ70Wsxd1%2F1E4lwnxFQr%2F5cz&b=5&f=norefer" 
    headers = ["accept-encoding": "gzip, deflate, br",
               "accept-language": "en-US,en;q=0.8,ko;q=0.6",
               "upgrade-insecure-requests": "1",
               "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36",
               "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
               "cache-control": "max-age=0",
               "authority": "us.hideproxy.me",
               "cookie": "s=6scknffclr05pucb5j940j2rq0; c[mercari.com][/][merCtx]=%22%22; _ga=GA1.2.1790029790.1507523816; _gid=GA1.2.149312154.1510890269'"
              ]

    {:ok, resp} = HTTPoison.get(url, headers, [timeout: 50_000, recv_timeout: 50_000])
    res = Floki.find(resp.body, ".items-box")
    |> Enum.map(fn x -> Floki.find(x, "a") end)
    # |> IO.inspect
  end

  def translate_to_korean(txt) do
    url = "https://translation.googleapis.com/language/translate/v2?key=#{key(:google_api)}"
    post_body = %{
      "source" => "ja",
      "target" => "ko",
      "q" => txt
    }
    |> Poison.encode!
    {:ok, resp} = HTTPoison.post(url, post_body, %{"Content-Type" => "application/json"})

    resp.body
    |> Poison.decode!
    |> extract_translated_text
  end

  def extract_translated_text(%{"data" => %{"translations" => list}}) do
    list |> List.first |> Map.get("translatedText")
  end

  def key(:google_api), do: Application.get_env(:scatchers, __MODULE__)[:google_api_key]

end
