class IssuesController < ApplicationController
  
  disable_layout_for_ajax
  
  def index
    params[:offset] ||= 0
    @issues = Issue.get_issues(params, 12, params[:offset].to_i) 
  end
  
  def more
    index
  end
  
  def new
    @issue = Issue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @issue }
    end
  end
  
  def create
    image_count = params[:image_count].to_i
    image_ids = []
    (0..image_count-1).each do |i|
      image_ids << params["image_#{i}"]
    end

    @user.create_issue(params[:issue][:title], params[:issue][:category_id], params[:issue][:city_id], params[:issue][:description], params[:issue][:lat], params[:issue][:long],image_ids)
    redirect_to issues_path()
  end
  
  def show
    ActiveRecord::Base.transaction do
      @issue = Issue.find(params[:id])
      # Can't update View Count if this is your issue
      # TODO Refactor this
      @issue.mark_as_viewed(cookies[:unique])

      @already_voted = !(@issue.votes.where(:user_id => @user.id).first.nil?)
    end
  end

  def destroy
    issue = Issue.find(params[:id])
    if @user.id == issue.user_id
      issue.status = Issue::DELETED
      issue.save!
      flash[:info] = 'Uspjesno izbrisan'
    else
      flash[:error] = 'Neuspjesno brisanje!'
    end

    redirect_to issues_url()
  end
  
  def vote
    @user.vote_for(params[:id])
    render :json => { :ok => true }
  end

  def unvote
    @user.unvote_for(params[:id])
    render :json => { :ok => true }
  end

  def follow
    @user.follow(params[:id])
    redirect_to issues_path()
  end
end