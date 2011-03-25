class FortunesController < ApplicationController
  def index
    @fortunes = Fortune.all
  end

  def show
    @fortune = Fortune.find(params[:id])
  end

  def new
    @fortune = Fortune.new
  end

  def create
    @fortune = Fortune.new(params[:fortune])
    if @fortune.save
      redirect_to @fortune, :notice => "Successfully created fortune."
    else
      render :action => 'new'
    end
  end

  def edit
    @fortune = Fortune.find(params[:id])
  end

  def update
    @fortune = Fortune.find(params[:id])
    if @fortune.update_attributes(params[:fortune])
      redirect_to @fortune, :notice  => "Successfully updated fortune."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @fortune = Fortune.find(params[:id])
    @fortune.destroy
    redirect_to fortunes_url, :notice => "Successfully destroyed fortune."
  end
end
