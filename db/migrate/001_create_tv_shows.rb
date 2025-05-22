Sequel.migration do
  change do
    create_table :tv_shows do
      primary_key :id
      Integer :tvmaze_id, null: false, unique: true
      String :name, null: false
      String :type
      String :language
      String :status
      Integer :runtime
      Date :premiered
      Date :ended
      Float :rating
      DateTime :created_at
      DateTime :updated_at

      index :tvmaze_id, unique: true
      index :name
      index :status
      index :rating
    end
  end
end
