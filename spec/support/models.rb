require 'has_children'

class Item < ActiveRecord::Base
  has_children

  scope :alphabetic, ->{ order 'name asc' }
end
