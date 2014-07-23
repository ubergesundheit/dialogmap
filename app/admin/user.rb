ActiveAdmin.register User do

  permit_params :email, :name

  form do |f|
    f.inputs do
      f.input :email
      f.input :name
    end
    f.actions
  end

end
