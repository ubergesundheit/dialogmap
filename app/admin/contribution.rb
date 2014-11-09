ActiveAdmin.register Contribution do

  permit_params :title, :description, :deleted, :delete_reason, :properties, :category_color, :activity_icon,
    :page_description, :page_who, :page_when, :page_how, :page_where, :page_contact, :page_actor

  index do
    selectable_column
    id_column
    column :title
    column :description
    column :created_at
    column :updated_at
    column :deleted
    column :delete_reason
    column :start_date
    column :end_date
    column :user, :sortable => :user_id
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
      f.input :start_date
      f.input :end_date
      f.input :category, input_html: { disabled: true }
      f.input :category_color, input_html: { type: 'color' }
      f.input :activity, input_html: { disabled: true }
      f.input :activity_icon
      f.input :page_actor
      f.input :page_description
      f.input :page_who
      f.input :page_when
      f.input :page_how
      f.input :page_where
      f.input :page_contact
    end
    f.actions
  end

end
