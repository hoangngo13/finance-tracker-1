class User < ApplicationRecord
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friend_ships
  has_many :friends, through: :friend_ships
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  def stock_already_tracked?(ticker_symbol)
    stock = Stock.check_db(ticker_symbol)
    return false unless stock
    stocks.where(id: stock.id).exists?
  end

  def under_stock_limit?
    stocks.count < 10
  end

  def can_track_stock?(ticker_symbol)
    under_stock_limit? && !stock_already_tracked?(ticker_symbol)
  end

  def full_name
    return "#{first_name} #{last_name}" if first_name || last_name
    "No Name"
  end

  def self.search(param)
    search_result = (email_matches(param) + first_name_matches(param) + last_name_matches(param)).uniq
    return search_result.empty? ? nil : search_result
  end
  
  def self.email_matches(param)
    matches('email', param)
  end

  def self.first_name_matches(param)
    matches('first_name', param)
  end

  def self.last_name_matches(param)
    matches('last_name', param)
  end

  def self.matches(field_name, param)
    where("#{field_name} like ?","%#{param}%")
  end
  
  def friend_already_followed?(friend)
    friends.where(id: friend.id).exists?
  end

  def except_current_user(users)
    users.reject { |user| user.id == self.id }
  end
end
