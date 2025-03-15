class Api::V1::BackgroundCollectionsController < Api::V1::BaseController
  before_action :set_background_collection, only: [:show, :update, :destroy, :make_default]

  def index
    background_collections = @shop.background_collections
    render json: background_collections, each_serializer: BackgroundCollectionSerializer, adapter: :json
  end

  def new
    background_collection = @shop.background_collections.new

    count = @shop.background_collections.count + 1
    background_collection[:name] = "Background Collection ##{count}"

    render json: background_collection, serializer: BackgroundCollectionSerializer, adapter: :json
  end

  def create
    background_collection = @shop.background_collections.new

    if background_collection.save
      render json: background_collection, serializer: BackgroundCollectionSerializer, status: :created, adapter: :json
    else
      render json: background_collection.errors, status: :unprocessable_entity
    end
  end

  def add_new
    background_collection = @shop.background_collections.new

    if background_collection.save
      background_collection.update(background_collection_params)
      render json: background_collection, serializer: BackgroundCollectionSerializer, status: :created, adapter: :json
    else
      render json: background_collection.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @background_collection, serializer: BackgroundCollectionSerializer, adapter: :json
  end

  def make_default
    @shop.background_collections.update_all(default: false)

    if @background_collection.update(default: true)
      render json: @background_collection, serializer: BackgroundCollectionSerializer, adapter: :json
    else
      render json: @background_collection.errors, status: :unprocessable_entity
    end
  end

  def update
    if @background_collection.update(background_collection_params)
      render json: @background_collection, serializer: BackgroundCollectionSerializer, adapter: :json
    else
      render json: @background_collection.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @shop.background_collections.count == 1 # can't delete last
      render json: { error: "You can't delete last background collection" }, status: :unprocessable_entity
    else
      @background_collection.destroy if @background_collection

      set_first_background_collection_default if @background_collection[:default]

      head :no_content
    end
  end

  private

  def background_collection_params
    params.permit(:name, :default, bg_images: [:order, :src, :width_in_mm, :paintable])
  end

  def set_background_collection
    @background_collection = @shop.background_collections.find(params[:id])
  end

  def set_first_background_collection_default
    @shop.background_collections.first.update(default: true)
  end
end
