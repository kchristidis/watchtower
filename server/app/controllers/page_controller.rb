class PageController < ApplicationController
  def all
    respond_to do |format|
      format.json { render json: DataPoint.all }
    end
  end

  def show
    render id
  end

  def simple_line
    respond_to do |format|
      format.json { render json: DataPoint.simple_line(params) }
      format.html
    end
  end

  def dashboard
  end

  def welcome
    if current_user
      redirect_to current_user
    else
      @user ||= User.new
      respond_to do |format|
        format.json { render json: DataPoint.by_sensor_id.each {|e| e["sensor_id"] = rand.round} }
        format.html
      end
    end
  end

  private def id
    params[:id]
  end

  private def action_allowed?
    case params[:action]
    when 'welcome'
      true
    end
  end
end
