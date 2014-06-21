ActiveAdmin.register Contribution do

  permit_params :title, :description, :deleted, :delete_reason, :properties

  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :deleted
      f.input :delete_reason
    end
    f.actions
  end

end
