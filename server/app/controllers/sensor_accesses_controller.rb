class SensorAccessesController < ApplicationController
  before_action :set_sensor_access, only: [:show, :edit, :update, :destroy]

  # GET /sensor_accesses
  # GET /sensor_accesses.json
  def index
    @sensor_accesses = SensorAccess.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sensor_accesses }
    end
  end

  # GET /sensor_accesses/1
  # GET /sensor_accesses/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sensor_access }
    end
  end

  # GET /sensor_accesses/new
  def new
    @sensor_access = SensorAccess.new
    @sensor_access.sensor_id = params[:sensor_id]
    @sensor_access.sensor_module_id = @sensor_access.sensor.sensor_module_id
  end

  # GET /sensor_accesses/1/edit
  def edit
  end

  # POST /sensor_accesses
  # POST /sensor_accesses.json
  def create
    user = User.where('id = ? OR username = ?', params[:sensor_access][:user_id].to_i, params[:sensor_access][:user_id]).first
    params[:sensor_access]['user_id'] = user.try(:id)
    @sensor_access = SensorAccess.new(sensor_access_params)

    respond_to do |format|
      if user && @sensor_access.save
        flash[:success] = 'Sensor access was successfully created.'
        format.html { redirect_to @sensor_access }
        format.json { render json: @sensor_access, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @sensor_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sensor_accesses/1
  # PATCH/PUT /sensor_accesses/1.json
  def update
    respond_to do |format|
      if @sensor_access.update(sensor_access_params)
        flash[:success] = 'Sensor access was successfully updated.'
        format.html { redirect_to @sensor_access }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sensor_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sensor_accesses/1
  # DELETE /sensor_accesses/1.json
  def destroy
    sensor = @sensor_access.sensor
    @sensor_access.destroy
    respond_to do |format|
      flash[:success] = 'Sensor access deleted'
      format.html { redirect_to sensor }
      format.json { head :no_content }
    end
  end

  private
    def action_allowed?
      :always # todo lock it down
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_sensor_access
      @sensor_access = SensorAccess.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sensor_access_params
      params.require(:sensor_access)
        .permit(
      :sensor_id,
      :sensor_module_id,
      :user_id,
      )
    end
end
