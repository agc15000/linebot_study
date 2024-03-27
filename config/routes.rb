Rails.application.routes.draw do
  post '/' => 'linebot#callback'
end
