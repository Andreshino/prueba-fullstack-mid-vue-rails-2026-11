employees = [
  {
    name: "Ana María Gómez",
    document: "1020304050",
    phone_number: "3001234567",
    position: "Auxiliar contable",
    address: "Calle 10 # 20-30",
    city: "Bogotá"
  },
  {
    name: "Carlos Andrés Pérez",
    document: "1098765432",
    phone_number: "3109876543",
    position: "Conductor",
    address: "Carrera 45 # 12-18",
    city: "Medellín"
  },
  {
    name: "Laura Sofía Ramírez",
    document: "52987654",
    phone_number: "3205558899",
    position: "Asistente administrativa",
    address: "Avenida 6N # 23-45",
    city: "Cali"
  },
  {
    name: "Jorge Iván Torres",
    document: "80456789",
    phone_number: "3154447788",
    position: "Jefe de bodega",
    address: "Calle 30 # 8-12",
    city: "Barranquilla"
  },
  {
    name: "Diana Carolina López",
    document: "1012456789",
    phone_number: "3016662211",
    position: "Analista de nómina",
    address: "Transversal 15 # 40-22",
    city: "Bucaramanga"
  }
]

employees.each do |attributes|
  Employee.find_or_create_by!(document: attributes[:document]) do |employee|
    employee.assign_attributes(attributes)
  end
end

puts "Empleados cargados: #{Employee.count}"
