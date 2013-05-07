class MessagesController < ApplicationController
  def create
    message = Message.new
    message.text = params[:message][:text]
    message.user = User.find_by_name(params[:user_name])

    if (message.save)
      render :json => message.to_json, :status => 201
    else
      render :status => 422
    end

  end

  def index
    last_message = params[:last_message].to_i
    if(last_message.nil?)
      render :json => Message.all.to_json, :status=>201
    else
      render :json => Message.all(:conditions => ["id > ?",last_message]), :status=>201
    end
  end
end
