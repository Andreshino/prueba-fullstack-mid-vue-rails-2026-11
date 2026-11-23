class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees do |t|
      t.string :name, null: false
      t.string :document, null: false
      t.string :phone_number, null: false
      t.string :position, null: false
      t.string :address, null: false
      t.string :city, null: false

      t.timestamps
    end
  end
end
