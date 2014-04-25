class CartodbController < ApplicationController

  BASE_URL = 'https://ubergesundheit.cartodb.com/api/v2/sql?q='

  def sql
    render json: HTTParty.get("https://ubergesundheit.cartodb.com/api/v2/sql?q=SELECT%20count%28*%29%20FROM%20contributions")

  end


end
