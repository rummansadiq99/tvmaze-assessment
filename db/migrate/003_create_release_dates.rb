Sequel.migration do
  change do
    create_table :release_dates do
      primary_key :id
      foreign_key :tv_show_id, :tv_shows, null: false
      foreign_key :distributor_id, :distributors, null: false
      Date :release_date, null: false
      String :country, null: false
      DateTime :created_at
      DateTime :updated_at

      index :release_date
      index [:tv_show_id, :distributor_id, :release_date], unique: true
      index :country
    end
  end
end
