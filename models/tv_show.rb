class TVShow < Sequel::Model
  plugin :timestamps
  plugin :validation_helpers

  many_to_many :distributors, join_table: :release_dates
  one_to_many :release_dates

  def validate
    super
    validates_presence [:name, :tvmaze_id]
    validates_unique :tvmaze_id
  end

  def self.find_or_create_by_tvmaze_id(tvmaze_id, attributes)
    find_or_create(tvmaze_id: tvmaze_id) do |show|
      show.update(attributes)
    end
  end

  def to_api
    {
      id: id,
      tvmaze_id: tvmaze_id,
      name: name,
      type: type,
      language: language,
      status: status,
      runtime: runtime,
      premiered: premiered,
      ended: ended,
      rating: rating,
      distributors: distributors.map(&:to_api),
      release_dates: release_dates.map(&:to_api)
    }
  end
end
