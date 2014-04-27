class Api::ContributionsController < Api::BaseController
  before_action :set_contribution, only: [:show, :update, :destroy]

  # GET /contributions
  # GET /contributions.json
  def index
    @contributions = Contribution.all
  end

  # GET /contributions/1
  # GET /contributions/1.json
  def show
    render json: @contribution.as_json(include: :features)
  end

  # POST /contributions
  # POST /contributions.json
  def create
    @contribution = Contribution.new(contribution_params)

    if @contribution.save
      render json: @contribution.as_json(include: :features), status: :created
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contributions/1
  # PATCH/PUT /contributions/1.json
  def update
    respond_to do |format|
      if @contribution.update(contribution_params)
        format.html { redirect_to @contribution, notice: 'Contribution was successfully updated.' }
        format.json { render :show, status: :ok, location: @contribution }
      else
        format.html { render :edit }
        format.json { render json: @contribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contributions/1
  # DELETE /contributions/1.json
  def destroy
    @contribution.destroy
    respond_to do |format|
      format.html { redirect_to contributions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contribution
      @contribution = Contribution.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contribution_params
      allowed_properties = params['contribution']['features_attributes'].try(:collect) do |f|
        f['geojson']['properties'].try(:keys)
      end.try(:flatten).try(:uniq) || []
      allowed_properties << ""
      params.require(:contribution).permit(
        :title,
        :description,
        features_attributes: [
          {
            geojson: [
              :type,
              { geometry: [
                  :type,
                  { coordinates: [] },
                  coordinates: [[]]
                ]
              },
              { properties: allowed_properties }
            ]
          }
        ]
      ).tap do |whitelisted|
        whitelisted['features_attributes'].try(:each_index) do |i|
          whitelisted['features_attributes'][i]['geojson']['geometry']['coordinates'] = params['contribution']['features_attributes'][i]['geojson']['geometry']['coordinates']
        end
      end
    end
end
