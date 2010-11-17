class UserSession < Authlogic::Session::Base
  # configuration here, see documentation for sub modules of Authlogic::Session
  def to_key
    new_record? ? nil : [ self.send(self.class.primary_key) ]
  end
end
