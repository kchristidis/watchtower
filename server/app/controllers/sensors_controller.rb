class SensorsController < ApplicationController
  before_action :set_sensor, only: [:show, :edit, :update, :destroy]

  # GET /sensors
  # GET /sensors.json
  def index
    @sensors = SensorModule.find_by(id: params[:sensor_module_id]).sensors || Sensor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sensors }
    end
  end

  # GET /sensors/1
  # GET /sensors/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sensor }
    end
  end

  # GET /sensors/new
  def new
    @sensor = Sensor.new
    @sensor.sensor_module_id = params[:sensor_module_id]
  end

  # GET /sensors/1/edit
  def edit
  end

  # POST /sensors
  # POST /sensors.json
  def create
    @sensor = Sensor.new(sensor_params)

    respond_to do |format|
      if @sensor.save
        flash[:success] = 'Sensor was successfully created.'
        format.html { redirect_to @sensor }
        format.json { render json: @sensor, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sensors/1
  # PATCH/PUT /sensors/1.json
  def update
    respond_to do |format|
      if @sensor.update(sensor_params)
        flash[:success] = 'Sensor was successfully updated.'
        format.html { redirect_to @sensor }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sensors/1
  # DELETE /sensors/1.json
  def destroy
    sensor_module = @sensor.sensor_module
    @sensor.destroy
    respond_to do |format|
      flash[:success] = 'Sensor deleted'
      format.html { redirect_to sensor_module }
      format.json { head :no_content }
    end
  end

  private
    def action_allowed?
      :always # todo lock it down
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_sensor
      @sensor = Sensor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sensor_params
      params.require(:sensor).permit(:name, :sensor_module_id)
    end
end
