module Shoppe
  class ProductReviewsController < Shoppe::ApplicationController
    before_filter { @active_nav = :products }
    before_filter { params[:product_id] && @product = Shoppe::Product.root.find(params[:product_id]) }
  
    def index
      @product_reviews = @product.reviews.all
    end
  
    def new
      @product_review = Shoppe::ProductReview.new
    end
  
    def create
      @product_review = Shoppe::ProductReview.new(safe_params)
      @product.reviews << @product_review
      if @product_review.save
        redirect_to :product_product_reviews, :flash => {:notice => "Отзыв добавлен"}
      else
        render :action => "new"
      end
    end
  
    def edit
      @product_review = Shoppe::ProductReview.find(params[:id])
    end
  
    def update
      @product_review = Shoppe::ProductReview.find(params[:id])
      if @product_review.update(safe_params)
        redirect_to [:edit, @product, @product_review], :flash => {:notice => "Отзыв обновлен"}
      else
        render :action => "edit"
      end
    end
  
    def destroy
      @product_review = Shoppe::ProductReview.find(params[:id])
      @product_review.destroy
      redirect_to :product_product_reviews, :flash => {:notice => "Отзыв удален"}
    end
  
    private
  
    def safe_params
      params[:product_review].permit(:author, :text, :pro, :contra, :grade, :convenience_grade, :price_grade, :quality_grade, :public, :agree, :reject)
    end
  
  end
end
