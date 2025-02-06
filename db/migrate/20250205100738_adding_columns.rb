class AddingColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :is_archived, :boolean, default: false
    add_column :notes, :colour, :string, default: "white"
  end
end
