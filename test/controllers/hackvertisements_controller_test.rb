require "test_helper"

class HackvertisementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hackvertisement = hackvertisements(:one)
  end

  test "should get index" do
    get hackvertisements_url
    assert_response :success
  end

  test "should get new" do
    get new_hackvertisement_url
    assert_response :success
  end

  test "should create hackvertisement" do
    assert_difference("Hackvertisement.count") do
      post hackvertisements_url, params: { hackvertisement: { data: @hackvertisement.data, date: @hackvertisement.date, link: @hackvertisement.link, user_id: @hackvertisement.user_id } }
    end

    assert_redirected_to hackvertisement_url(Hackvertisement.last)
  end

  test "should show hackvertisement" do
    get hackvertisement_url(@hackvertisement)
    assert_response :success
  end

  test "should get edit" do
    get edit_hackvertisement_url(@hackvertisement)
    assert_response :success
  end

  test "should update hackvertisement" do
    patch hackvertisement_url(@hackvertisement), params: { hackvertisement: { data: @hackvertisement.data, date: @hackvertisement.date, link: @hackvertisement.link, user_id: @hackvertisement.user_id } }
    assert_redirected_to hackvertisement_url(@hackvertisement)
  end

  test "should destroy hackvertisement" do
    assert_difference("Hackvertisement.count", -1) do
      delete hackvertisement_url(@hackvertisement)
    end

    assert_redirected_to hackvertisements_url
  end
end
