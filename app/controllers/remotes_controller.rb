class RemotesController < ApplicationController

  include RemotesHelper

	def new
		@remote = Remote.new
	end

	def create
		@user = current_user if current_user
		@remote = Remote.make(@user)
		dispatch = @remote.populate(params[:video_url])
		@remote.name = params[:name] unless params[:name] == ''
		@remote.description = params[:description] unless params[:description] == ''
		@remote.admin_only = to_boolean(params[:admin_only]) || false
		@remote.save
		flash[dispatch[:status]] = dispatch[:message]
		redirect_to dispatch[:path]
	end

	def edit
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
		@remote_owner = @user if @user == @remote.user
	end

	def update
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
    @remote_owner = @user if @user == @remote.user
    if @remote_owner
    	@remote.update(params)
    end
    render json: {'remote' => @remote}.to_json
	end

	def control
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
    @remote_owner = @user if @user == @remote.user
    @remote.control_update(params, @remote_owner)
    render nothing: true
	end

	def ping
		@remote = Remote.find_by({remote_id: params[:id]})
		@playlist = @remote.playlist
		render json: {'start_at' => @remote.start_at, 'status' => @remote.status, 'updated_at' => @remote.updated_at, 'dispatched_at' => Time.now, 'sender_id' => 'fremote_server', 'selection' => @playlist.selection, 'stream_url' => URI::encode(ViddlRb.get_urls(@playlist.list[@playlist.selection]["url"]).first), 'playlist' => @playlist.list, 'watchers' => @remote.watchers }.to_json
	end

	def show
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
		@remote_owner = @user if @user == @remote.user
		@remote_json = @remote.json
		@identifier = (Time.now.strftime('%Y%m%d%H%M%S%L%N') + rand(400).to_s).to_s
		@username = Chat.guest_display_name
		@playlist = Playlist.new
	end

	def chat
		@remote = Remote.find_by({remote_id: params[:id]})
		Notify.new("chat:#{@remote.remote_id}", {'message' => params["chat_message"], 'name' => params["username"] })
		render nothing: true
	end

	def time
		render json: {time: Time.now}.to_json
	end

end
