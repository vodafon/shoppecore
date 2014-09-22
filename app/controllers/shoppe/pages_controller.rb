module Shoppe
  class PagesController < Shoppe::ApplicationController
  
    before_filter { @active_nav = :pages }
  
    def index
      @pages = Shoppe::Page.all
    end
    
    def new
      @page = Shoppe::Page.new
    end
  
    def create
      @page = Shoppe::Page.new(safe_params)
      if @page.save
        redirect_to :pages, :flash => {:notice => "Страница добавлена"}
      else
        render :action => "new"
      end
    end
  
    def edit
      @page = Shoppe::Page.find(params[:id])
    end
  
    def update
      @page = Shoppe::Page.find(params[:id])
      if @page.update(safe_params)
        redirect_to [:edit, @page], :flash => {:notice => "Страница обновлена"}
      else
        render :action => "edit"
      end
    end
  
    def destroy
      @page = Shoppe::Page.find(params[:id])
      @page.destroy
      redirect_to :pages, :flash => {:notice => "Страница удалена"}
    end
    
    private
  
    def safe_params
      params[:page].permit(:name, :permalink, :info, :title, :text)
    end
  end
end
