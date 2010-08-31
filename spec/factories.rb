Factory.define :user do |user|
  user.name                  'Michael Hartl'
  user.email                 'mhartl@example.com'
  user.password              'foobar'
  user.password_confirmation 'foobar'
end

Factory.sequence :email do |i|
  "person-#{i}@example.com"
end
