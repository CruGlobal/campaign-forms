# frozen_string_literal: true

class FormsController < ApplicationController
  # Create is an external API
  protect_from_forgery except: :create

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    load_form
  end

  def create
    load_form
    render(json: profile.errors, status: :bad_request) and return unless profile.valid?
    AdobeCampaignWorker.perform_async(@form.id, profile.params, master_person_id)

    response = { master_person_id: master_person_id }
    response[:redirect_url] = @form.redirect_url if @form.redirect_url
    render json: response, status: :ok
  end

  private

  def load_form
    @form ||= Form.find(params[:id])
  end

  def profile
    @profile ||= Profile.new(@form, params)
  end

  def master_person_id
    @master_person_id ||= MasterPersonId.new(@form, @profile.params).find_or_create_id
  end

  def record_not_found(error)
    render json: { error: error.message }, status: :not_found
  end
end
