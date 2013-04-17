class UsersController < ApplicationController
  def create
    user = User.new
    user.name = params[:user]
    logger.debug(params)

      if (user.save)
      render :json => user.to_json, :status => 201
      else 
      render :json => {}.to_json, :status => 422
    end

  end
end
