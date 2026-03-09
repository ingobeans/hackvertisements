class HomeController < ApplicationController
  def index
    puts User.all.count()
  end
end
