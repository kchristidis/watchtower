class DataPointsController < ApplicationController
  before_action :set_data_point, only: [:show, :edit, :update, :destroy]

  # GET /data_points
  # GET /data_points.json
  def index
    from = DateTime.parse (params[:from] || DateTime.now.to_s)
    to = DateTime.parse (params[:to] || DateTime.now.to_s)
    @data_points = DataPoint
      .where(sensor_id: (params[:sensor_id].split(',') || current_user.all_sensor_ids))
      .where("timestamp > ? AND timestamp < ?", from, to)
      .order(timestamp: :desc)
      .limit(params[:limit] || 100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data_points }
    end
  end

  # GET /data_points/1
  # GET /data_points/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @data_point }
    end
  end

  # GET /data_points/new
  def new
    @data_point = DataPoint.new
  end

  # GET /data_points/1/edit
  def edit
  end

  # POST /data_points
  # POST /data_points.json
  def create
    @data_point = DataPoint.new(data_point_params)

    respond_to do |format|
      if @data_point.save
        format.html { redirect_to @data_point, notice: 'Data point was successfully created.' }
        format.json { render json: @data_point, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @data_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /data_points/1
  # PATCH/PUT /data_points/1.json
  def update
    respond_to do |format|
      if @data_point.update(data_point_params)
        format.html { redirect_to @data_point, notice: 'Data point was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @data_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_points/1
  # DELETE /data_points/1.json
  def destroy
    @data_point.destroy
    respond_to do |format|
      format.html { redirect_to data_points_url }
      format.json { head :no_content }
    end
  end

  private
    def action_allowed?
      params[:action] == 'index'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_data_point
      @data_point = DataPoint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def data_point_params
      params.require(:data_point)
        .permit(:sensor_id, :data, :timestamp)
    end
end
