# frozen_string_literal: true

require "rails_helper"
require "capybara/rails"

RSpec.describe Admin::UsersController, type: :controller do
  render_views

  context "signed-in" do
    before(:each) do
      @user = create(:user, has_access: true)
      sign_in @user
    end

    describe "GET index" do
      it "returns users" do
        # Prepare
        user2 = create(:user)

        # Test
        get :index

        # Verify
        expect(response.status).to eq(200)
        expect(response.body).to have_content(@user.username)
        expect(response.body).to have_content(@user.first_name)
        expect(response.body).to have_content(@user.last_name)
        expect(response.body).to have_content(user2.username)
        expect(response.body).to have_content(user2.first_name)
        expect(response.body).to have_content(user2.last_name)
      end
    end

    describe "GET new" do
      it "renders form for new user" do
        # Test
        get :new

        # Verify
        expect(response.status).to eq(200)
        expect(response.body).to have_field("First name")
        expect(response.body).to have_field("Last name")
        expect(response.body).to have_field("Username")
        expect(response.body).to have_field("Has access")
      end
    end

    describe "POST create" do
      it "creates one user" do
        # Prepare
        user_attributes = {
          username: Faker::Lorem.word,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          has_access: false,
        }

        # Test and verify
        expect {
          post :create, params: {user: user_attributes}
        }.to change(User, :count).by(1)
        new_user = User.where(username: user_attributes[:username]).first
        expect(new_user).to be
        expect(new_user.first_name).to eq(user_attributes[:first_name])
        expect(new_user.last_name).to eq(user_attributes[:last_name])
        expect(new_user.has_access).to eq(user_attributes[:has_access])
        expect(response).to redirect_to(admin_user_path(new_user))
      end
    end

    describe "GET edit" do
      it "should get user for edit" do
        # Prepare
        user = create(:user)

        # Test
        get :edit, params: {id: user.id}

        # Verify
        expect(response.status).to eq(200)
        expect(response.body).to have_field("Username", with: user.username)
        expect(response.body).to have_field("First name", with: user.first_name)
        expect(response.body).to have_field("Last name", with: user.last_name)
        expect(response.body).to have_field("Has access", checked: true)
      end
    end

    describe "PUT update" do
      it "updates the user" do
        # Prepare
        user = create(:user)
        user_new_attributes = {
          username: Faker::Lorem.word,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          has_access: false,
        }

        # Test
        put :update, params: {id: user.id, user: user_new_attributes}

        # Verify
        expect(response).to redirect_to(admin_user_path(user))

        updated_user = User.find(user.id)
        expect(updated_user).to be
        expect(updated_user.username).to eq(user_new_attributes[:username])
        expect(updated_user.first_name).to eq(user_new_attributes[:first_name])
        expect(updated_user.last_name).to eq(user_new_attributes[:last_name])
        expect(updated_user.has_access).to eq(user_new_attributes[:has_access])
      end
    end

    describe "GET show" do
      it "shows the user" do
        # Prepare
        user = create(:user)

        # Test
        get :show, params: {id: user.id}

        # Verify
        expect(response.status).to eq(200)
        expect(response.body).to have_content(user.username)
        expect(response.body).to have_content(user.first_name)
        expect(response.body).to have_content(user.last_name)
      end
    end

    describe "DELETE destroy" do
      it "deletes user" do
        # Prepare
        user = create(:user)

        # Test
        delete :destroy, params: {id: user.id}

        # Verify
        expect(response).to redirect_to(admin_users_path)
        expect {
          User.find(user.id)
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "signed non-admin" do
    before(:each) do
      @user = create(:user, has_access: false)
      sign_in @user
    end

    describe "GET index" do
      it "returns something" do
        # Test
        get :index

        # Verify
        expect(response.status).to eq(401)
        expect(response.body).to match(/Permission Denied/)
      end
    end

    describe "after_sign_out_path_for" do
      it "returns logout url" do
        session["id_token"] = "id_token"

        # Test
        result = controller.after_sign_out_path_for("anything")

        # Verify
        expect(result).to eq("issuer/v1/logout?id_token_hint=id_token&post_logout_redirect_uri=http://test.host")
      end
    end
  end
end
