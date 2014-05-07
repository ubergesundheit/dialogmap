class Reference < ActiveRecord::Base

  before_save :map_reference

  private
    def map_reference
      binding.pry
    end
end
