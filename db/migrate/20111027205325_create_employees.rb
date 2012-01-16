class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table :employees do |t|
      t.timestamps
      t.column :username, :string, :unique => true
      t.column :name, :string
      t.column :email, :string
      t.column :aim, :string
      t.column :gchat, :string
      t.column :mobile, :string
      t.column :twitter, :string
      t.column :github, :string
    end
  end

  def self.down
    drop_table :employees
  end
end
