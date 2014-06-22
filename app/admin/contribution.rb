ActiveAdmin.register Contribution do

  permit_params :title, :description, :deleted, :delete_reason, :properties, :category_color

  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :deleted
      f.input :delete_reason
      f.input :category, input_html: { disabled: true }
      f.input :category_color, input_html: { type: 'color' }
    end
    f.actions
  end

end
