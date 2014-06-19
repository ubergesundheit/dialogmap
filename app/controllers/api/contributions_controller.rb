class Api::ContributionsController < Api::BaseController
  before_action :set_contribution, only: [:show, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  # GET /contributions
  # GET /contributions.json
  def index
    if bbox_params != {}
      render json: Contribution.only_parents.within(bbox_params)
    elsif ids_params != {}
      render json: Contribution.find(ids_params.split(","))
    else
      render json: Contribution.only_parents
    end
  end

  # GET /contributions/1
  # GET /contributions/1.json
  def show
    render json: @contribution
  end

  # POST /contributions
  # POST /contributions.json
  def create
    @contribution = Contribution.new(contribution_params)

    set_user!

    if @contribution.save
      render json: @contribution
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contributions/1
  # PATCH/PUT /contributions/1.json
  def update
    if current_user == @contribution.user
      if @contribution.update(contribution_params)
        render json: @contribution
      else
        render json: @contribution.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'you are not allowed to do that' }, status: :forbidden
    end
  end

  # DELETE /contributions/1
  # DELETE /contributions/1.json
  def destroy
    if current_user == @contribution.user
      if @contribution.update({ deleted: true })
        render json: @contribution
      else
        render json: @contribution.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'you are not allowed to do that' }, status: :forbidden
    end
  end

  # GET /contributions/categories
  def categories
    render json: Contribution.categories.map{ |c| { id: c.cat, text: c.cat } unless c.cat == nil  }.compact
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
        :delete_reason,
        :deleted,
        :category,
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
        references_attributes: [ :type, :ref_id, :title, :id ]
      ).tap do |whitelisted|
        whitelisted['features_attributes'].try(:each_index) do |i|
          whitelisted['features_attributes'][i]['geojson']['geometry']['coordinates'] = params['contribution']['features_attributes'][i]['geojson']['geometry']['coordinates']
        end
      end
    end
end
