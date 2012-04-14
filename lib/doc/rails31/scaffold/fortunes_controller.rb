class FortunesController < ApplicationController
  # GET /fortunes
  # GET /fortunes.json
  def index
    @fortunes = Fortune.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fortunes }
    end
  end

  # GET /fortunes/1
  # GET /fortunes/1.json
  def show
    @fortune = Fortune.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fortune }
    end
  end

  # GET /fortunes/new
  # GET /fortunes/new.json
  def new
    @fortune = Fortune.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fortune }
    end
  end

  # GET /fortunes/1/edit
  def edit
    @fortune = Fortune.find(params[:id])
  end

  # POST /fortunes
  # POST /fortunes.json
  def create
    @fortune = Fortune.new(params[:fortune])

    respond_to do |format|
      if @fortune.save
        format.html { redirect_to @fortune, notice: 'Fortune was successfully created.' }
        format.json { render json: @fortune, status: :created, location: @fortune }
      else
        format.html { render action: "new" }
        format.json { render json: @fortune.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fortunes/1
  # PUT /fortunes/1.json
  def update
    @fortune = Fortune.find(params[:id])

    respond_to do |format|
      if @fortune.update_attributes(params[:fortune])
        format.html { redirect_to @fortune, notice: 'Fortune was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fortune.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fortunes/1
  # DELETE /fortunes/1.json
  def destroy
    @fortune = Fortune.find(params[:id])
    @fortune.destroy

    respond_to do |format|
      format.html { redirect_to fortunes_url }
      format.json { head :no_content }
    end
  end
end
