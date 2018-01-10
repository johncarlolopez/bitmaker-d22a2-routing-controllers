Rails.application.routes.draw do
  get '/welcome' => 'pages#welcome'
  get '/' => 'pages#welcome'
  get '/about' => 'pages#about'
  get '/contest' => 'pages#contest'
  get '/kitten/:size' => 'pages#kitten'
  get '/kittens/:size' => 'pages#kittens'
end
