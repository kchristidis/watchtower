class SensorModuleAccessesController < ApplicationController
  before_action :set_sensor_module_access, only: [:show, :edit, :update, :destroy]

  # GET /sensor_module_accesses
  # GET /sensor_module_accesses.json
  def index
    @sensor_module_accesses = SensorModuleAccess.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sensor_module_accesses }
    end
  end

  # GET /sensor_module_accesses/1
  # GET /sensor_module_accesses/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sensor_module_access }
    end
  end

  # GET /sensor_module_accesses/new
  def new
    @sensor_module_access =
      SensorModuleAccess.new(
        sensor_module_id: params[:sensor_module_id]
    )

  end

  # GET /sensor_module_accesses/1/edit
  def edit
  end

  # POST /sensor_module_accesses
  # POST /sensor_module_accesses.json
  def create
    user = User.where('id = ? OR username = ?', params[:sensor_module_access][:user_id].to_i, params[:sensor_module_access][:user_id]).first
    params[:sensor_module_access]['user_id'] = user.try(:id)
    @sensor_module_access = SensorModuleAccess.new(sensor_module_access_params)

    respond_to do |format|
      if user && @sensor_module_access.save
        flash[:success] = 'Sensor module access was successfully created.'
        format.html { redirect_to @sensor_module_access.sensor_module }
        format.json { render json: @sensor_module_access, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @sensor_module_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sensor_module_accesses/1
  # PATCH/PUT /sensor_module_accesses/1.json
  def update
    respond_to do |format|
      if @sensor_module_access.update(sensor_module_access_params)
        flash[:success] = 'Sensor module access was successfully updated.'
        format.html { redirect_to @sensor_module_access.sensor_module }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sensor_module_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sensor_module_accesses/1
  # DELETE /sensor_module_accesses/1.json
  def destroy
    sensor_module = @sensor_module_access.sensor_module
    @sensor_module_access.destroy
    respond_to do |format|
      format.html { redirect_to sensor_module }
      format.json { head :no_content }
    end
  end

  private
    def action_allowed?
      :always # todo lock it down
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_sensor_module_access
      @sensor_module_access = SensorModuleAccess.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sensor_module_access_params
      params.require(:sensor_module_access).permit(:sensor_module_id, :user_id)
    end
end
