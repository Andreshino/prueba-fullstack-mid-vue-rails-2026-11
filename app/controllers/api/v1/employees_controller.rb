class Api::V1::EmployeesController < ApplicationController
  def index
    employees = EmployeeService.new.list

    render json: {
      employees: employees.as_json(
        only: %i[id name document phone_number position address city]
      )
    }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
