class CreateAnswerchoices < ActiveRecord::Migration
  def change
    create_table :answer_choices do |t|
      t.string :choice
      t.integer :question_id

      t.timestamps
    end
  end
end
