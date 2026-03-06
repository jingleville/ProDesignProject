class AllowNullCommentableInComments < ActiveRecord::Migration[7.2]
  def change
    change_column_null :comments, :commentable_type, true
    change_column_null :comments, :commentable_id, true
  end
end
