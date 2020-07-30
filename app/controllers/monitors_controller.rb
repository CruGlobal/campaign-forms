# frozen_string_literal: true

class MonitorsController < ApplicationController
  protect_from_forgery with: :exception

  layout nil

  def lb
    render plain: File.read(Rails.public_path.join("lb.txt"))
  end
end
