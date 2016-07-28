class TestModelsController < ApplicationController
  before_action :set_test_model, only: [:show, :edit, :update, :destroy]

  # GET /test_models
  def index
    @test_models = TestModel.all
  end

  # GET /test_models/1
  def show
  end

  # GET /test_models/new
  def new
    @test_model = TestModel.new
  end

  # GET /test_models/1/edit
  def edit
  end

  # POST /test_models
  def create
    @test_model = TestModel.new(test_model_params)

    if @test_model.save
      redirect_to @test_model, notice: 'Test model was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /test_models/1
  def update
    if @test_model.update(test_model_params)
      redirect_to @test_model, notice: 'Test model was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /test_models/1
  def destroy
    @test_model.destroy
    redirect_to test_models_url, notice: 'Test model was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_model
      @test_model = TestModel.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def test_model_params
      params.require(:test_model).permit(:title, :body, :user_id)
    end
end
