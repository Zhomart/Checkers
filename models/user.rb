class User
  include Jongoid::Document

  field :username
  field :name

  field :signed_in_at

  def update_user_sign_in
    self.signed_in_at = Time.now.to_i
    save
  end

end
