require 'spec_helper'

describe "FriendlyForwardings" do
  it 'forwards to the requested page after signin' do
    user = Factory(:user)
    visit edit_user_path(user)  # this redirects to the signin page
    fill_in :email,    :with => user.email
    fill_in :password, :with => user.password
    click_button                # this should redirect to the originally requested URL
    response.should render_template('users/edit')
  end
end
