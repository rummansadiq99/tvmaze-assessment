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
end
