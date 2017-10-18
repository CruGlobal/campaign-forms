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
    render_create_form
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

  def render_create_form
    data = { master_person_id: master_person_id, campaign_code: @form.campaign_code }
    data[:redirect_url] = @form.redirect_url if @form.redirect_url
    render json: data, status: :ok
  end
end
