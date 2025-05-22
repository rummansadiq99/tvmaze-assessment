Sequel.migration do
  change do
    create_table :distributors do
      primary_key :id
      String :name, null: false
      String :country, null: false
      DateTime :created_at
      DateTime :updated_at

      index [:name, :country], unique: true
      index :country
    end
  end
end
