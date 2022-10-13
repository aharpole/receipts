class AddDefaultStatusToImport < ActiveRecord::Migration[6.0]
  def change
    change_column_default :import_statuses, :status, from: nil, to: 0
    ImportStatus.where(status: nil).update_all(status: 0)
  end
end
