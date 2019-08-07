module V2
  class DepositsController < ResourceController

    def create
      @deposit = Deposit.create!(
        artifact: Artifact.find_by_artifact_id!(params[:artifact_id]),
        user: current_user,
        status: :started # TODO: control these with a value type
      )
      render json: @deposit, status: 201, location: v2_deposit_path(@deposit)
    end

  end
end
