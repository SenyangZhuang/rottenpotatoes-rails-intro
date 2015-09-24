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
        if params.length == 2 && session[:last_params] != nil && session[:saved_args].length > 2
            redirect_to movies_path(session[:last_params])
            return
        end

        session[:last_params] = params

        @all_ratings = Movie.all.select('rating').distinct

        if params[:commit] == "Refresh"
            if params[:ratings] != nil
               @ratings_set = params[:ratings].keys
            elsif  session[:rating_box].nil?
                @ratings_set = @all_ratings
            else
                @ratings_set = session[:rating_box]
            end
            session[:rating_box] = @ratings_set
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
