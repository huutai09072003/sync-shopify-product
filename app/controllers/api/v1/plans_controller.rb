class Api::V1::PlansController < Api::V1::BaseController
  def index
    shop_id = params[:shop_id]

    return render json: { error: "shop_id is required" }, status: :bad_request if shop_id.blank?

    @plans = Plan.where(shop_id: shop_id)
    
    if Time.current > Time.new(2025, 1, 31)
      @plans = @plans.reject { |plan| plan.name.include?("Exclusive") }
    else
      exclusive_plans = @plans.select { |plan| plan.name.include?("Exclusive") }
      render json: exclusive_plans, each_serializer: PlanSerializer and return if exclusive_plans.any?
    end

    render json: @plans, each_serializer: PlanSerializer
  end
end