class TVShowsAPI < Sinatra::Base
  get '/v1/tvshows' do
    content_type :json

    # Parse query parameters
    date_from = params['date_from'] ? Date.parse(params['date_from']) : Date.today
    date_to = params['date_to'] ? Date.parse(params['date_to']) : (Date.today + 90)
    distributor = params['distributor']
    country = params['country']
    rating = params['rating']&.to_f
    page = (params['page'] || 1).to_i
    per_page = (params['per_page'] || 20).to_i

    # Build query
    query = TVShow
      .join(:release_dates, tv_show_id: :id)
      .join(:distributors, id: :distributor_id)
      .where(release_date: date_from..date_to)

    # Apply filters
    query = query.where(distributors__name: distributor) if distributor
    query = query.where(release_dates__country: country) if country
    query = query.where(rating: rating) if rating

    # Get total count for pagination
    total_count = query.count

    # Apply pagination
    shows = query
      .select_all(:tv_shows)
      .distinct
      .order(:release_date)
      .limit(per_page)
      .offset((page - 1) * per_page)
      .all

    # Prepare response
    response = {
      shows: shows.map(&:to_api),
      pagination: {
        total: total_count,
        page: page,
        per_page: per_page,
        total_pages: (total_count.to_f / per_page).ceil
      }
    }

    # Add cache headers
    headers['Cache-Control'] = 'public, max-age=3600'
    headers['ETag'] = Digest::MD5.hexdigest(response.to_json)

    json response
  end
end
