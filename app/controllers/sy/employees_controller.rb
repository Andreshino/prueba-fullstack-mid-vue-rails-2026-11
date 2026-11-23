class Sy::EmployeesController < ApplicationController
  def index
    render "sy/modules/employees/index", layout: "application_vue"
  end
end
