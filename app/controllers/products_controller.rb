class ProductsController < ApplicationController

    def new
        if logged_in?
            @product = Product.new
            @product.build_chem_group #for the nested form. Builds the chem_group attributes
            @product.build_application_area
            @product.build_category
        else
            flash[:error] = "Sorry, you must be logged in to create a new product."
            redirect_to products_path
        end
    end

    def create
        @product = Product.new(product_params)
        @product.user_id = session[:user_id] #bc product belongs_to user. user_id required from model
        if @product.save #validation
            # @product.image.purge
            # @product.image.attach(params[:product][:image]) # allows image to be replaced if user changes image
            redirect_to product_path(@product)
        else
            @product.build_chem_group
            @product.build_application_area
            @product.build_category
            render :new
        end
    end

    def edit
        #The "create a new chem_group" needs to be blank. It's pre-filling with the existing chem group
        #It needs to be either/or. Use the same chem_group and keep "new" blank OR create new chem_group and dump
        #the already existing one.
        find_product
        if @product.user != current_user
            flash[:error] = "Sorry, you can only edit your own products"
            redirect_to products_path
        end
    end

    def update
        find_product
        if @product.update(product_params)
            redirect_to product_path(@product)
        else
            render :edit
        end
    end

    def index
        @products = Product.order_by_rating
    end

    def show
        find_product
        @user = User.find_by(id: params[:user])
    end

    def most_reviews
        @product = Product.most_reviews.first
    end

    def destroy
        find_product
        if logged_in?
            @product.destroy
            redirect_to products_path, notice: 'Product successfully deleted.'
        else
            flash[:error] = "Sorry, you can only delete your own products"
            render product_path(@product)
        end
    end

    private

    def product_params
        params.require(:product).permit(:name, :description, :active_ingredient, :image, :chem_group_id, :application_area_id, :category_id, chem_group_attributes: [:id, :name], application_area_attributes: [:id, :area_name], category_attributes: [:id, :name])
        #chem_group_id and chem_group_attributes [:name] is permitting elements from new product form
    end

    def find_product
        @product = Product.find_by(id: params[:id])
    end

end
