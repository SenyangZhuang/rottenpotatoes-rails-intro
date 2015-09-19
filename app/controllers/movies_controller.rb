class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def showbyname
    @movies = Movie.order("title ASC").all
  end

  def showbydate
    @movies = Movie.order("release_date ASC").all
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def retrive_collection
    return Movie.all.select('rating').distinct
  end
  
  def index
    @all_ratings = retrive_collection()
    @checked_ratings_set = []
    if params.length == 2 && session[:saved_args] != nil && session[:saved_args].length > 2
      redirect_to movies_path(session[:saved_args])
      return
    end
    session[:saved_args] = params
    if params[:sortby] != nil
      if params[:sortby]["title"] != nil
        @thclass_title = "hilite"
        @movies = Movie.order("title ASC").all
      elsif params[:sortby]["date"] != nil
        @thclass_date = "hilite"
        @movies = Movie.order("release_date ASC").all
      else
        @movies = Movie.all
      end
    else
      @movies = Movie.all
    end

    if params[:commit] == "Refresh"
      if params[:ratings] != nil
        @checked_ratings_set = params[:ratings].keys
        session[:checked_rating_box] = @checked_ratings_set
      end
    end
    
    if session[:checked_rating_box].nil?
      @all_ratings.each do |rating| @checked_ratings_set<<rating.rating
      end
    else
      @checked_ratings_set = session[:checked_rating_box]
    end
    @movies = @movies.nil? ? [] : @movies.select {|m| @checked_ratings_set.include?(m.rating)}
    
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
