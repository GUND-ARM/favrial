# frozen_string_literal: true

require "test_helper"

class NavBarComponentTest < ViewComponent::TestCase
  def test_render_component
    user = User.find_or_create_from_auth_hash(auth_hash)
    component = NavBarComponent.new(user)
    render_inline(component)
    assert_selector("a.dropdown-item", text: "AIで仮分類済(スレミオ, スレミオ判断, 2023/05)")
    assert_selector("a.dropdown-item", text: "AIで仮分類済(スレミオ, スレミオ判断, 2023/04)")
    assert_selector("a.dropdown-item", text: "AIで仮分類済(スレミオ, スレミオ判断, 2023/03)")
    assert_selector("a.dropdown-item", text: "AIで仮分類済(スレミオ, スレミオ判断, 2023/02)")
    assert_selector("a.dropdown-item", text: "AIで仮分類済(スレミオ, スレミオ判断, 2023/01)")
    assert_selector("a.dropdown-item", text: "AIで仮分類済(スレミオ, スレミオ判断, 2022/12)")
    assert_selector("a.dropdown-item", text: "AIで仮分類済(スレミオ, スレミオ判断, 2022/11)")
    assert_selector("a.dropdown-item", text: "AIで仮分類済(スレミオ, スレミオ判断, 2022/10)")
  end
end
