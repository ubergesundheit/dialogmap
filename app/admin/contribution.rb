ActiveAdmin.register Contribution do

  permit_params :title, :description, :deleted, :delete_reason, :properties, :category_color, :activity_icon

  index do
    selectable_column
    id_column
    column :title
    column :description
    column :created_at
    column :updated_at
    column :deleted
    column :delete_reason
    column :category do |color|
      raw("<span class=\"status_tag\" style=\"color: black;border:1px solid black;background:#{color.category_color};\">#{color.category}</span>")
    end
    column :activity do |activity|
      raw("<div class=\"maki-icon #{activity.activity_icon}\"></div>#{activity.activity}")
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :deleted
      f.input :delete_reason
      f.input :category, input_html: { disabled: true }
      f.input :category_color, input_html: { type: 'color' }
      f.input :activity, input_html: { disabled: true }
      f.input :activity_icon
    end
    f.actions
  end

end
