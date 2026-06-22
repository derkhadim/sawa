phone_counter = 2
next_phone = -> { phone_counter += 1; "+22177#{format('%07d', phone_counter)}" }

# Super Admin
User.create!(
  email: 'admin@loca.com',
  phone: next_phone.call,
  password: 'password123',
  first_name: 'Super',
  last_name: 'Admin',
  role: 'super_admin'
)

# 2 Agences
agencies = [
  Agency.create!(
    name: 'Agence Immobilière Dakar',
    address: '123 Rue Principale, Dakar',
    phone: next_phone.call,
    email: 'contact@agence-dakar.com'
  ),
  Agency.create!(
    name: 'Groupe Patrimoine Sénégal',
    address: '67 Boulevard de la République, Dakar',
    phone: next_phone.call,
    email: 'contact@groupe-patrimoine.sn'
  )
]

# 2 Agents (un par agence)
agents = agencies.map.with_index do |agency, i|
  User.create!(
    email: %w[agent@loca.com agent2@loca.com][i],
    phone: next_phone.call,
    password: 'password123',
    first_name: 'Agent',
    last_name: %w[Principal Sene][i],
    role: 'agence',
    agency: agency
  )
end

# 6 Immeubles (3 par agence)
buildings_data = [
  { agency: agencies[0], name: 'Résidence Les Cocotiers',     address: '45 Avenue de la République', neighborhood: 'Fann', commune: 'Dakar' },
  { agency: agencies[0], name: 'Villa Oasis',                 address: '12 Rue des Manguiers',      neighborhood: 'Sicap', commune: 'Dakar' },
  { agency: agencies[0], name: 'Immeuble Le Rayon',           address: '8 Boulevard du Sud',        neighborhood: 'Mermoz', commune: 'Dakar' },
  { agency: agencies[1], name: 'Résidence du Port',           address: '23 Quai des Pêcheurs',      neighborhood: 'Gorée', commune: 'Dakar' },
  { agency: agencies[1], name: 'Cité Baobab',                 address: '55 Avenue Cheikh Anta Diop',neighborhood: 'Ouakam', commune: 'Dakar' },
  { agency: agencies[1], name: 'Résidence Les Hibiscus',      address: '3 Rue de la Plage',         neighborhood: 'Ngor', commune: 'Dakar' }
]

tenant_counter = 0

buildings_data.each do |bd|
  owner = Owner.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone: next_phone.call,
    email: Faker::Internet.email,
    agency: bd[:agency]
  )

  building = Building.create!(
    name: bd[:name],
    address: bd[:address],
    neighborhood: bd[:neighborhood],
    commune: bd[:commune],
    latitude: 14.6937 + rand(-0.05..0.05),
    longitude: -17.4441 + rand(-0.05..0.05),
    owner: owner,
    agency: bd[:agency]
  )

  # 20 locations par immeuble
  (1..20).each do |n|
    tenant_counter += 1
    tenant = User.create!(
      email: "tenant#{tenant_counter}@loca.com",
      phone: next_phone.call,
      password: 'password123',
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      role: 'tenant',
      building: building
    )

    f = (n - 1) / 5 + 1
    rent = [120_000, 150_000, 200_000, 250_000].sample

    apt = Apartment.create!(
      number: "#{f}#{format('%02d', n)}",
      floor: f,
      rent_amount: rent,
      status: 'occupied',
      building: building,
      tenant: tenant
    )

    now = Time.current
    Payment.create!(
      amount: rent,
      due_date: Date.new(now.year, now.month, 12),
      month: now.month,
      year: now.year,
      status: %w[pending paid late].sample,
      apartment: apt,
      tenant: tenant
    )
  end

  # 1 appartement libre
  Apartment.create!(
    number: "X1",
    floor: 5,
    rent_amount: 300_000,
    status: 'free',
    building: building
  )
end

# Locataire sans appartement (test onboarding)
User.create!(
  email: 'nouveau@loca.com',
  phone: next_phone.call,
  password: 'password123',
  first_name: 'Nouveau',
  last_name: 'Locataire',
  role: 'tenant'
)

puts "Seeds created successfully!"
puts "2 agences, 6 immeubles, 120 locataires"
puts "Super Admin: admin@loca.com / password123"
puts "Agent: agent@loca.com / password123"
puts "Agent 2: agent2@loca.com / password123"
puts "Sans appart: nouveau@loca.com / password123"
