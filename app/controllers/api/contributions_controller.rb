class Api::ContributionsController < Api::BaseController
  before_action :set_contribution, only: [:show, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  # GET /contributions
  # GET /contributions.json
  def index
    if bbox_params != {}
      render json: Contribution.only_parents.within(bbox_params).as_json(include: { features: {}, references: { include: :reference_to }, user: {}, children_contributions: {} })
    elsif ids_params != {}
      render json: Contribution.find(ids_params.split(",")).as_json(include: { features: {}, references: { include: :reference_to }, user: {}, children_contributions: {} })
    else
      render json: Contribution.only_parents.as_json(include: { features: {}, references: { include: :reference_to }, user: {}, children_contributions: {} })
    end
  end

  # GET /contributions/1
  # GET /contributions/1.json
  def show
    render json: @contribution.as_json(include: { features: {}, references: { include: :reference_to }, user: {}, children_contributions: {} })
  end

  # POST /contributions
  # POST /contributions.json
  def create
    @contribution = Contribution.new(contribution_params)

    set_user!

    if @contribution.save
      render json: @contribution.as_json(include: { features: {}, references: { include: :reference_to }, user: {}, children_contributions: {} }), status: :created
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

    def set_user!
      @contribution.user_id = current_user.id
    end

    def bbox_params
      params.fetch(:bbox,{})
    end

    def ids_params
      params.fetch(:ids,{})
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
        :parent_id,
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
          },
          :leaflet_id
        ],
        references_attributes: [ :type, :ref_id, :title ]
      ).tap do |whitelisted|
        whitelisted['features_attributes'].try(:each_index) do |i|
          whitelisted['features_attributes'][i]['geojson']['geometry']['coordinates'] = params['contribution']['features_attributes'][i]['geojson']['geometry']['coordinates']
        end
      end
    end
end
