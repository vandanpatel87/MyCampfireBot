class Employee < ActiveRecord::Base
  def to_s
    [:name, :email, :aim, :gchat, :mobile, :twitter, :github].collect {|attr| "#{(attr.to_s.humanize + ':').ljust(10)} #{send(attr)}"}.join("\n")
  end
end
