class Employee < ApplicationRecord
  validates :name, :document, :phone_number, :position, :address, :city, presence: true
end
