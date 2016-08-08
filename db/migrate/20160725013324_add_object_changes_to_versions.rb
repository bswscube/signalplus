# This migration adds the optional `object_changes` column, in which PaperTrail
# will store the `changes` diff for each update event. See the readme for
# details.
class AddObjectChangesToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :object_changes, :jsonb
    add_index :versions, :object_changes
  end
end
