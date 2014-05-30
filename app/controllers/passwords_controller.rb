class PasswordsController < Devise::PasswordsController
  layout false

  def create
    user = User.find_by_login params[:user][:login]
    if user.nil?
      flash[:error] = "Unknown user #{params[:user][:login]}"
      redirect_to new_user_password_path
    else
      if user.send_reset_password_instructions
        flash[:notice] = 'Just sent password reset mail'
        redirect_to new_user_session_path
      else
        flash[:error] = '?????????????'
        redirect_to new_user_password_path
      end
    end
  end
end