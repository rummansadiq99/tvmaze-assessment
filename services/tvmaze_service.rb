require 'httparty'

class TVMazeService
  include HTTParty
  base_uri 'https://api.tvmaze.com'

  def initialize
    @options = {
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    }
  end

  def fetch_upcoming_shows(days: 90)
    start_date = Date.today
    end_date = start_date + days

    shows = []
    current_date = start_date

    while current_date <= end_date
      response = self.class.get("/schedule", @options.merge(query: { date: current_date.strftime('%Y-%m-%d') }))

      if response.success?
        shows.concat(response.parsed_response)
      else
        raise "Failed to fetch shows for #{current_date}: #{response.code} - #{response.message}"
      end

      current_date += 1
    end

    shows
  end

  def fetch_show_details(tvmaze_id)
    response = self.class.get("/shows/#{tvmaze_id}", @options)

    if response.success?
      response.parsed_response
    else
      raise "Failed to fetch show details for #{tvmaze_id}: #{response.code} - #{response.message}"
    end
  end

  private

  def handle_rate_limit(response)
    if response.code == 429
      retry_after = response.headers['Retry-After'].to_i
      sleep retry_after
      return true
    end
    false
  end
end
