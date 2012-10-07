require 'erb'
def relative path
  File.join(File.dirname(__FILE__), path)
end
require relative('../../app/models/market/item')
require relative('../../app/models/market/user')

class Marketplace < Sinatra::Application

  post "/buy_item" do
    redirect '/login' unless session[:name]

    @owner = Market::User.user_by_name(params[:owner])
    @item = @owner.item_by_id(params[:item].to_i)
    
    @current_user = Market::User.user_by_name(session[:name])

    begin
      @current_user.buy_item(@item)
    rescue Exception => e
      halt erb :error, :locals => {:message => e.message}
    end

    redirect back

  end

  post "/status_change" do
    redirect '/login' unless session[:name]

    @owner = Market::User.user_by_name(params[:owner])
    @item = @owner.item_by_id(params[:item].to_i)
    @current_user = Market::User.user_by_name(session[:name])

    if @current_user == @owner
      @item.inactivate if params[:new_state] == "inactive"
      @item.activate if params[:new_state] == "active"
    end
    redirect back
  end

  post "/edit_item" do
    redirect '/login' unless session[:name]

    @owner = Market::User.user_by_name(params[:owner])
    @item = @owner.item_by_id(params[:item].to_i)
    @current_user = Market::User.user_by_name(session[:name])

    if @current_user == @owner
      @item.name = params[:item_name]
      @item.price = params[:item_price]
    end
    redirect back
  end

end
