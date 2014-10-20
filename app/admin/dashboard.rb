ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    h2 do
      "Seiten"
    end
    columns do
      column do
        h2 do
          panel "Seiten bearbeiten" do
            link_to('Seiten bearbeiten', '/cms')
          end
        end
      end
    end

    h2 do
      "Karteneinstellungen"
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
  end # content
end
