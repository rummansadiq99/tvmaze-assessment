class ReleaseDate < Sequel::Model
  plugin :timestamps
  plugin :validation_helpers

  many_to_one :tv_show
  many_to_one :distributor

  def validate
    super
    validates_presence [:tv_show_id, :distributor_id, :release_date, :country]
  end

  def self.find_or_create_by_show_and_distributor(tv_show_id, distributor_id, attributes)
    find_or_create(
      tv_show_id: tv_show_id,
      distributor_id: distributor_id,
      release_date: attributes[:release_date]
    ) do |release|
      release.update(attributes)
    end
  end

  def to_api
    {
      id: id,
      tv_show_id: tv_show_id,
      distributor_id: distributor_id,
      release_date: release_date,
      country: country
    }
  end
end
