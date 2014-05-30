class SessionsController < Devise::SessionsController
  layout false
  def create
    user = User.find_by_login params[:login]
    if !user.nil? && user.migrated?
      if user.send_reset_password_instructions
        flash[:notice] = 'Just sent password reset mail.'
        redirect_to new_user_session_path
      else
        flash[:error] = 'Unknown devise error. Ask to your webistrano server team.'
        redirect_to new_user_password_path
      end
    else
      super
    end
  end
end
