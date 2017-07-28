class PostsController < ApplicationController
  before_action :set_post, only: [:show, :show_with_restriction, :edit, :update, :destroy, :show_target_image]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @x_cell_num = params[:x_cell_num]&.to_i
    unless @x_cell_num&.nonzero?
      @x_cell_num = 10
    end
    @canny_num_min = params[:canny_num_min]&.to_i
    unless @x_cell_num&.nonzero?
      @canny_num_min = 50
    end
    @canny_num_max = params[:canny_num_max]&.to_i
    unless @canny_num_max&.nonzero?
      @canny_num_max = 150
    end
    @num_array = @post.convert2string(@x_cell_num)
    gon.num_array = @num_array
    gon.width = @post.image.first
    gon.height = @post.image.last
  end

  def show_with_restriction
    show
    render :show
  end

  def show_target_image
    image = Magick::Image.read(@post.absolute_photo_path).first
    @cropped_image = image.crop(params[:x].to_i,
                                params[:y].to_i,
                                params[:w].to_i,
                                params[:h].to_i)
    @cropped_image.write('public/images/show_num.jpg')
    @num_string = params[:num]
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:photo)
    end
end
