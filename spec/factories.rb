Factory.define :user do |f|
  f.password_confirmation { |u| u.password }
end

Factory.define :album do |f|
end

Factory.define :collection do |f|
end