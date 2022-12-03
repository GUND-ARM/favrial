# frozen_string_literal: true

class NavBarComponent < ViewComponent::Base
  def initialize(current_user)
    @current_user = current_user
  end
end
