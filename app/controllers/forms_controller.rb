# frozen_string_literal: true

class FormsController < ApplicationController
  def create
    return unless required_params
    AdobeCampaignWorker.perform_async(params[:campaign], person.person_attrs)
    render json: { master_person_id: master_person_id }, status: :ok
  end

  private

  def required_params
    render_error errors: { campaign: 'Campaign missing' } and return false if campaign.blank?
    render_error errors: person.errors and return false unless person.valid?
    true
  end

  def render_error(errors:, status: :bad_request)
    render json: errors, status: status
  end

  def campaign
    @campaign ||= params[:campaign]
  end

  def person
    @person ||= Person.new(params.permit(Person::PERSON_ATTRIBUTES))
  end

  def master_person_id
    @master_person_id ||= MasterPersonId.new(person).find_or_create_id
  end
end
