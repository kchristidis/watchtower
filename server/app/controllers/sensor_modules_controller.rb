class SensorModulesController < ApplicationController
  before_action :set_sensor_module, only: [:show, :edit, :update, :destroy]

  # GET /sensor_modules
  # GET /sensor_modules.json
  def index
    @sensor_modules = SensorModule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sensor_modules }
    end
  end

  # GET /sensor_modules/1
  # GET /sensor_modules/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sensor_module }
    end
  end

  # GET /sensor_modules/new
  def new
    @sensor_module = SensorModule.new user: current_user
  end

  # GET /sensor_modules/1/edit
  def edit
  end

  # POST /sensor_modules
  # POST /sensor_modules.json
  def create
    @sensor_module = SensorModule.find_by(id: sensor_module_params[:id]) ||
      SensorModule.new(sensor_module_params)

    respond_to do |format|
      if @sensor_module.update_attributes(sensor_module_params)
        flash[:success] = 'Sensor module was successfully created.'
        format.html { redirect_to @sensor_module }
        format.json { render json: @sensor_module, status: :created }
      else
        flash[:error] = "The sensor module with id=#{@sensor_module.id} could not be found."
        format.html { render action: 'new' }
        format.json { render json: @sensor_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sensor_modules/1
  # PATCH/PUT /sensor_modules/1.json
  def update
    respond_to do |format|
      if @sensor_module.update(sensor_module_params)
        flash[:success] = 'Sensor module was successfully updated.'
        format.html { redirect_to @sensor_module }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sensor_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sensor_modules/1
  # DELETE /sensor_modules/1.json
  def destroy
    user = @sensor_module.user
    @sensor_module.update_attributes(user_id: nil)
    respond_to do |format|
      flash[:success] = 'Sensor module deleted'
      format.html { redirect_to user }
      format.json { head :no_content }
    end
  end

  private

    def action_allowed?
      :always # todo lock it down
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_sensor_module
      @sensor_module = SensorModule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sensor_module_params
      params.require(:sensor_module).permit(:id, :name, :location, :user_id)
    end
end
