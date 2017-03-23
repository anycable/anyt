# frozen_string_literal: true

class TransmitSubscriptionChannel < ApplicationCable::Channel
  def subscribed
    transmit('hello')
  end
end
