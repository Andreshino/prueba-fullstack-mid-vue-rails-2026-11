class EmployeeService
  def list
    Employee.order(:name)
  end
end
