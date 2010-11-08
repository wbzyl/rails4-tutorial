class FortunesController < ApplicationController
  # GET /fortunes
  # GET /fortunes.xml
  def index
    @fortunes = Fortune.all
    respond_with(@fortunes)
  end

  # GET /fortunes/1
  # GET /fortunes/1.xml
  def show
    @fortune = Fortune.find(params[:id])
    respond_with(@fortune)
  end

  # GET /fortunes/new
  # GET /fortunes/new.xml
  def new
    @fortune = Fortune.new
    #? respond_with(@fortune)
  end

  # GET /fortunes/1/edit
  def edit
    @fortune = Fortune.find(params[:id])
    #? respond_with(@fortune)
  end

  # POST /fortunes
  # POST /fortunes.xml
  def create
    @fortune = Fortune.new(params[:fortune])
    flash[:notice] = 'Fortune was successfully created.' if @fortune.save
    respond_with(@fortune)
  end

  # PUT /fortunes/1
  # PUT /fortunes/1.xml
  def update
    @fortune = Fortune.find(params[:id])
    flash[:notice] = 'Fortune was successfully updated.' if @fortune.update_attributes(params[:fortune])
    respond_with(@fortune)
  end

  # DELETE /fortunes/1
  # DELETE /fortunes/1.xml
  def destroy
    @fortune = Fortune.find(params[:id])
    @fortune.destroy
    respond_with(@fortune)
  end
end
