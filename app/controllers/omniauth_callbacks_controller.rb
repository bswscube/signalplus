class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.find_for_oauth(env["omniauth.auth"], current_user)

        if @user.persisted?
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
        else
          redirect_to root_url
        end
      end
    }
  end


  [:twitter, :facebook].each do |provider|
    provides_callback_for(provider)
  end

  # provider = :twitter
  # provides_callback_for(provider)

  def after_sign_in_path_for(resource)
    if resource.subscription?
      dashboard_index_path
    else
      subscription_plans_path
    end
  end
end
