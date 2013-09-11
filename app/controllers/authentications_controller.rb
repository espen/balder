class AuthenticationsController < ApplicationController
  def create
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    if authentication
      # User is already registered with application
      flash[:notice] = 'Signed in successfully.'
      sign_in_and_redirect(authentication.user)

    elsif current_user
      # User is signed in but has not already authenticated with this social network
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      current_user.apply_omniauth(omniauth)
      current_user.save

      flash[:notice] = 'Authentication successful.'
      redirect_to '/'

    else
      # User is new to this application
      user = User.new
      user.authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
      user.apply_omniauth(omniauth)

      if user.save
        flash[:notice] = 'User created and signed in successfully.'
        sign_in_and_redirect(user)
      else
        flash[:notice] = 'Couldn\'t create fresh authenticated account.'
        session[:omniauth] = omniauth.except('extra')
        redirect_to account_path
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    provider = @authentication.provider
    @authentication.destroy
    flash[:notice] = 'Successfully unlinked #{provider} account.'
    redirect_to account_path
  end

  private

  def sign_in_and_redirect(user)
    unless current_user
      user_session = UserSession.new(User.find_by_single_access_token(user.single_access_token))
      user_session.save
    end
    redirect_to '/'
  end
end
