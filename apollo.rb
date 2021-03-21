require 'rest-client'
require 'json'

class Apollo
  @getrevue_api = ""
  @spotify_id = ""
  @spotify_secret = ""

  def initialize()
    @getrevue_api = ENV["GETREVUE_API"] 
    @spotify_id = ENV["SPOTIFY_ID"] 
    @spotify_secret = ENV["SPOTIFY_SECRET"] 
  end

  def print_test()
    #change when want to use
    token = "BQBX8NDypM8pLUfm8yAMhibUqwDYmt8jp0C22RYpUJ8ITLBCUXcdXV-rc-M2GPY7XJsRTBZdzliAMl2sBuRY0NFGtC33ClL85A-fEuIqYSZ-AxBgWXlPnxQgi0Sdu6tOFKRIDz76hFWlL1yw44_S3pVzONceFjA"

    auth = {"Authorization": "Bearer #{token}"}

    playlist_id = "14kQzYmZpIRZmwrIBBKSxm"

    endpoint1 = RestClient.get(
"https://api.spotify.com/v1/playlists/#{playlist_id}/tracks",
headers=auth)

    data1 = JSON.parse(endpoint1)

    links = take_links(data1["items"])

    yt_links = get_youtube_links(links)

    issue_id = get_current_issue()

    put_yt_links_in_revue(issue_id, yt_links)
  end

  def put_yt_links_in_revue(issue_id, yt_links)
    auth = {"Authorization": "Bearer #{@getrevue_api}"}
    yt_links.each do |yt_link|
      res = RestClient.post("https://www.getrevue.co/api/v2/issues/#{issue_id}/items", {"issue_id"=>issue_id, "url" => yt_link}, headers = auth)
      puts res
    end
  end

  def take_links(items)
    links = Array.new
    items.each do |item|
      link = item["track"]["external_urls"]["spotify"]
      links.push(link)
    end
    links.shuffle.take(7)
  end

  def get_youtube_links(links)
    res = Array.new
    links.each do |link|
      endpoint2 = RestClient.get("https://api.song.link/v1-alpha.1/links?url=#{link}")
      data2 =  JSON.parse(endpoint2)
      res.push(data2["linksByPlatform"]["youtube"]["url"])
    end

    res
  end

  def get_current_issue()
    auth = {"Authorization": "Bearer #{@getrevue_api}"}
    endpoint3 = RestClient.get("https://www.getrevue.co/api/v2/issues/current", headers=auth)
    data3 = JSON.parse(endpoint3)
    data3[0]["id"]
  end
end

