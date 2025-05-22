class Distributor < Sequel::Model
  plugin :timestamps
  plugin :validation_helpers

  many_to_many :tv_shows, join_table: :release_dates
  one_to_many :release_dates

  def validateg
    super
    validates_presence [:name, :country]
  end

  def self.find_or_create_by_name_and_country(name, country)
    find_or_create(name: name, country: country)
  end

  def to_api
    {
      id: id,
      name: name,
      country: country
    }
  end
end
