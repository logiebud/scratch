require 'sinatra'
require 'sinatra/activerecord'
require_relative 'models/game'
require_relative 'models/word'

class WordleApp < Sinatra::Base
  enable :sessions

  configure do
    set :database_file, 'config/database.yml'
    set :views, './views' # Explicitly set views directory
    set :public_folder, './public' # Explicitly set public folder
  end

  get '/' do
    erb :index
  end

  post '/guess' do
    guess = params[:guess].downcase

    # Validate guess length
    if guess.length != 5
      session[:error] = "Guess must be 5 letters"
      redirect '/'
    end

    # Get or create game from session
    game_id = session[:game_id]
    if game_id
      game = Game.find(game_id)
    else
      word = Word.order('RANDOM()').first
      game = Game.create(word: word, guesses: [])
      session[:game_id] = game.id
    end

    # Add guess and check result
    result = game.check_guess(guess)
    game.guesses = (game.guesses || []) << { text: guess, result: result }
    game.save

    # Check if game is won or lost
    if result.all? { |r| r == :correct }
      session[:message] = "You won! The word was #{game.word.text}"
      session.delete(:game_id)
    elsif game.guesses.length >= 6
      session[:message] = "Game over! The word was #{game.word.text}"
      session.delete(:game_id)
    end

    erb :game, locals: {
      game: game,
      message: session[:message],
      error: session[:error]
    }
  end

  get '/leaderboard' do
    # Get top 10 players by number of wins
    top_players = Game.select('COUNT(*) as wins')
      .where("guesses @> '[{\"result\":[\"correct\",\"correct\",\"correct\",\"correct\",\"correct\"]}]'")
      .group('user_id')
      .order('wins DESC')
      .limit(10)
      .map do |result|
        {
          user: User.find(result.user_id),
          wins: result.wins
        }
      end

    erb :leaderboard, locals: { players: top_players }
  end

  # Start the application if ruby file executed directly
  run! if app_file == $0
end
