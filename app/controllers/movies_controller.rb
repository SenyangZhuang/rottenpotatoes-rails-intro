class MoviesController < ApplicationController
    
    def movie_params
        params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
    
    def show
        id = params[:id] # retrieve movie ID from URI route
        @movie = Movie.find(id) # look up movie by unique ID
        # will render app/views/movies/show.<extension> by default
    end
    
    
  def index
    @all_ratings = Movie.all.select('rating').distinct
    @ratings_set = []
    if params.length == 2 && session[:lastparams] != nil && session[:lastparams].length > 2
      redirect_to movies_path(session[:lastparams])
      return
    end
    session[:lastparams] = params
    
    if params[:commit] == "Refresh"
      if params[:ratings] != nil
        @ratings_set = params[:ratings].keys
        session[:rating_box] = @ratings_set
      end
    end
    
    if session[:rating_box].nil?
      @all_ratings.each do |x| 
        @ratings_set<<x.rating
      end
    else
      @ratings_set = session[:rating_box]
    end
   
    if params[:sortby] == "title"
      @thclass_title = "hilite"
      @movies = Movie.where(rating: @ratings_set).order(title: :asc)
    elsif params[:sortby] == "date"
      @thclass_date = "hilite"
      @movies = Movie.where(rating: @ratings_set).order(release_date: :asc)
    else
      @movies = Movie.where(rating: @ratings_set)
    end    
  end

    
    def new
        # default: render 'new' template
    end
    
    def create
        @movie = Movie.create!(movie_params)
        flash[:notice] = "#{@movie.title} was successfully created."
        redirect_to movies_path()
    end
    
    def edit
        @movie = Movie.find params[:id]
    end
    
    def update
        @movie = Movie.find params[:id]
        @movie.update_attributes!(movie_params)
        flash[:notice] = "#{@movie.title} was successfully updated."
        redirect_to movie_path(@movie)
    end
    
    def destroy
        @movie = Movie.find(params[:id])
        @movie.destroy
        flash[:notice] = "Movie '#{@movie.title}' deleted."
        redirect_to movies_path
    end
    
end
