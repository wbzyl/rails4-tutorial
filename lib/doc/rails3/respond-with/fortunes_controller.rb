class FortunesController < ApplicationController
  def index
    @fortunes = Fortune.all
    respond_with(@fortunes)
  end
  def show
    @fortune = Fortune.find(params[:id])
    respond_with(@fortune)
  end
  def new
    @fortune = Fortune.new
    respond_with(@fortune)
  end
  def edit
    @fortune = Fortune.find(params[:id])
  end
  def create
    @fortune = Fortune.new(params[:fortune])
    @fortune.save
    respond_with(@fortune)
  end
  def update
    @fortune = Fortune.find(params[:id])
    @fortune.update_attributes(params[:fortune])
    respond_with(@fortune)
  end
  def destroy
    @fortune = Fortune.find(params[:id])
    @fortune.destroy
    respond_with(@fortune)
  end
end
