module AuthorizationHelper
  def authorize
    unless action_allowed?
      flash[:error] = "Unauthorized for #{params[:controller]}\##{params[:action]}"
      redirect_back
    end
  end

  def action_allowed?(args={})
    # default behavior is unauthorized (this returns nil)
  end
end
