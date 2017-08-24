class AddColumnUserid < ActiveRecord::Migration[5.0]
  def change
      add_reference :posts, :user, index: true
  end
end
