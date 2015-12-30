class DashboardsController < ApplicationController
  before_action :set_dashboard, only: [:show, :edit, :update, :destroy]

  # GET /dashboards
  # GET /dashboards.json
  def index
    @dashboards = Dashboard.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dashboards }
    end
  end

  # GET /dashboards/1
  # GET /dashboards/1.json
  def show
    @user = @dashboard.user
    @accessible_sensors = @user.all_sensors
    @config = @dashboard.config || DashboardConfig.new.to_json
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dashboard }
    end
  end

  # GET /dashboards/new
  def new
    @dashboard = Dashboard.new(
      user_id: params[:user_id],
    )
  end

  # GET /dashboards/1/edit
  def edit
  end

  # POST /dashboards
  # POST /dashboards.json
  def create
    @dashboard = Dashboard.new(dashboard_params)

    respond_to do |format|
      if @dashboard.save
        flash[:success] = 'Dashboard was successfully created.'
        format.html { redirect_to @dashboard }
        format.json { render json: @dashboard, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @dashboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dashboards/1
  # PATCH/PUT /dashboards/1.json
  def update
    if params[:dashboard][:config]
      params[:dashboard][:config] = DashboardConfig.parse(params[:dashboard][:config]).to_json
    end
    respond_to do |format|
      if @dashboard.update(dashboard_params)
        flash[:success] = 'Dashboard was successfully updated.'
        format.html { redirect_to @dashboard }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dashboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dashboards/1
  # DELETE /dashboards/1.json
  def destroy
    user = @dashboard.user
    @dashboard.destroy
    respond_to do |format|
      format.html { redirect_to user }
      format.json { head :no_content }
    end
  end

  private
    def action_allowed?
      :always # todo lock it down
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_dashboard
      @dashboard = Dashboard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dashboard_params
      params.require(:dashboard).permit(:user_id, :config, :name)
    end
end
