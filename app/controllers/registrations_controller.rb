class RegistrationsController < Devise::RegistrationsController
  def update
    @user = User.find(current_user.id)

    successfully_updated = if needs_password?(@user)
      @user.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
    else
      # remove the virtual current_password attribute
      # update_without_password doesn't know how to ignore it
      params[:user].delete(:current_password)
      @user.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
    end

    if successfully_updated
      head :no_content
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  private

  # check if we need password to update user data
  # ie if user signed in via an external provider
  def needs_password?(user)
    Identity.where(user_id: user.id).count == 0
  end
end
