class AddAudioContentTypeToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :audio_content_type, :string
  end
end
