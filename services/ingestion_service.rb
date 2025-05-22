class IngestionService2
  def initialize(tvmaze_service = TVMazeService.new)
    @tvmaze_service = tvmaze_service
  end

  def ingest_upcoming_shows
    shows = @tvmaze_service.fetch_upcoming_shows
    process_shows(shows)
  end

  private

  def process_shows(shows)
    shows.each do |show_data|
      DB.transaction do
        # Create or update TV show
        tv_show = TVShow.find_or_create_by_tvmaze_id(
          show_data['show']['id'],
          {
            name: show_data['show']['name'],
            type: show_data['show']['type'],
            language: show_data['show']['language'],
            status: show_data['show']['status'],
            runtime: show_data['show']['runtime'],
            premiered: show_data['show']['premiered'],
            ended: show_data['show']['ended'],
            rating: show_data['show']['rating']&.fetch('average', nil)
          }
        )

        # Create or update distributor
        distributor = Distributor.find_or_create_by_name_and_country(
          show_data['show']['network']&.fetch('name', 'Unknown'),
          show_data['show']['network']&.fetch('country', {})&.fetch('code', 'Unknown')
        )

        # Create or update release date
        ReleaseDate.find_or_create_by_show_and_distributor(
          tv_show.id,
          distributor.id,
          {
            release_date: show_data['airdate'],
            country: show_data['show']['network']&.fetch('country', {})&.fetch('code', 'Unknown')
          }
        )
      end
    rescue StandardError => e
      puts "Error processing show #{show_data['show']['id']}: #{e.message}"
      next
    end
  end
end
