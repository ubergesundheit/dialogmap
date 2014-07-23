class UsersController < ApplicationController
  before_action :set_user, :finish_signup

  def finish_signup
    if request.patch? && params[:user] && params[:user][:email] && params[:user][:name]
      current_user.skip_reconfirmation!
      if current_user.update(user_params)
        sign_in(current_user, :bypass => true)
        redirect_to '/finish_signin.html'
      else
        @show_errors = true
        render :layout => 'application_without_angular'
      end
    elsif request.get? && current_user.email.match(User::TEMP_EMAIL_REGEX).nil?
      redirect_to '/finish_signin.html'
    else
      render :layout => 'application_without_angular'
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      accessible = [ :name, :email ] # extend with your own params
      accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
      params.require(:user).permit(accessible)
    end
end
