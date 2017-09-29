class CreateForms < ActiveRecord::Migration[5.1]
  def change
    create_table :forms, id: :uuid do |t|
      t.string :campaign_code
      t.string :name, null: false
      t.text :title
      t.text :body
      t.string :action
      t.text :success
      t.references :created_by, index: true

      t.timestamps
    end

    create_table :form_fields do |t|
      t.belongs_to :form, type: :uuid, null: false, index: true
      t.belongs_to :field, index: true
      t.string :label, default: nil
      t.string :help, default: nil
      t.boolean :required, default: false
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
