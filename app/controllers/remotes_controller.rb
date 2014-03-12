class RemotesController < ApplicationController

  include RemotesHelper

	def index
		@remote = Remote.new
	end

	def new
		@user = current_user if current_user
		@remote = Remote.new
	end

	def create
		@user = current_user if current_user
		@remote = Remote.make(@user)
    @remote.authorization.update_permissions(params)
		dispatch = @remote.populate(params[:video_url])
		@remote.populate_with_options_and_save(params, @user)
    flash[:notice] = "Congratulations!  Take control of your remote."
    redirect_to remote_path(@remote.remote_id)
	end

	def edit
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
		@remote_owner = @user if @user == @remote.user
		@members = @remote.member_list.members
	end

	def update
		p params
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
    @remote.update(params) if @remote.authorization.is_authorized?("settings", @user)

    respond_to do |format|
      format.json { render json: {'remote' => @remote}.to_json }
      format.html { redirect_to remote_path(@remote) }
    end
	end

	def control
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
    @remote_owner = @user if @user == @remote.user
    @remote.control(params, @remote_owner) if @remote.authorization.is_authorized?("settings", @user)
    render nothing: true
	end

	def ping
		@remote = Remote.find_by({remote_id: params[:id]})
		@playlist = @remote.playlist
		render json: {'start_at' => @remote.start_at, 'status' => @remote.status, 'updated_at' => @remote.updated_at, 'dispatched_at' => Time.now, 'sender_id' => 'fremote_server', 'selection' => @playlist.selection, 'stream_url' => URI::encode(Media.link(@playlist.list[@playlist.selection]["url"])), 'playlist' => @playlist.list, 'watchers' => @remote.watchers }.to_json
	end

	def show
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
		@remote_owner = @user if @user == @remote.user
		@remote_json = @remote.json
		@identifier = (Time.now.strftime('%Y%m%d%H%M%S%L%N') + rand(400).to_s).to_s
		@username = Chat.guest_display_name(@user, params[:guest_name])
		cookies[:username] = @username
		@playlist = Playlist.new
		@remote_name = @remote.name
		@remote_description = @remote.description
    @guest_name = Object.new
		render Remotes.what_to_render(@user, params[:guest_name])
	end

	def time
		render json: {time: Time.now}.to_json
	end

	private

end
