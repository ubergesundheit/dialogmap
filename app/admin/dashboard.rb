ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    h1 do
      "Bitte vorsichtig! Hier kann man mehr kaputt machen, als man denkt!"
    end

  columns do
    column do
      panel "User" do
        link_to('User', admin_users_path)
      end
    end
    column do
      panel "Contributions" do
        link_to('Contributions', admin_contributions_path)
      end
    end
  end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
