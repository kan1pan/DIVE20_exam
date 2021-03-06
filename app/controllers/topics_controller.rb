class TopicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_topic, only:[:show, :edit, :update, :destroy]

  def index
    @topics = Topic.all
    Topic.set_read
    @users = User.all
    @user = current_user
    @followeds = @user.followed_users
    @followers = @user.followers
    ajax_action unless params[:ajax_handler].blank?
  end

  def show
    @comment = @topic.comments.build
    @comments = @topic.comments
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.create(topic_params)
    @topic.user_id = current_user.id

    if @topic.content.length > 99
      @topic.update(read: true)
    end

    if @topic.save
      redirect_to topics_path, notice: "投稿しました！"
      NoticeMailer.sendmail_topic(@topic).deliver
    else
      render 'new'
    end
  end

  def edit
    if @topic.id != current_user.id
      redirect_to topics_path, notice: "投稿者でないため編集できませんでした..."
    end
  end

  def update
    if @topic.update(topic_params)
      redirect_to topics_path, notice: "投稿を更新しました！"
    else
      render 'new'
    end
  end

  def destroy
    @topic.destroy
    redirect_to topics_path, notice: "投稿を削除しました！"
  end

  def ajax_action
    if params[:ajax_handler] == 'content_more'
      respond_to do |format|
        @topic = Topic.find(params[:id])
        if @topic.update(read: false)
          format.html { redirect_to topics_path }
          format.js { render :index }
        end
      end
    end
  end

  private
    def topic_params
      params.require(:topic).permit(:title, :content, :image)
    end

    def set_topic
      @topic = Topic.find(params[:id])
    end

end
