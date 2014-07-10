class ConfirmationsController < Devise::ConfirmationsController

  private

    def after_confirmation_path_for(resource_name, resource)
      '/finish_confirmation.html'
    end

end
