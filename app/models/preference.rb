class Preference < ActiveRecord::Base

  def self.get(name, default = nil)
    value = Preference.where(:name=>name).first

    value || default
  end

  def self.get!(name, default = nil)
    value = Preference.where(:name=>name).first
  
    if value
      return value
    else
      Preference.set(name, default)
      return default
    end
  end

  def self.set(name, value)
    Preference.destroy_all(name: name)
    Preference.create(name: name, value: value)
  end

end
