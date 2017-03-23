# frozen_string_literal: true

require 'minitest/spec'
require 'minitest/hell'

module Anycablebility
  module Tests
    def self.define(client_factory)
      describe 'WebSocket server' do

        describe 'basic functionality' do
          it 'welcomes on connect' do
            client = client_factory.build
            assert_equal client.receive_parsed, { type: 'welcome' }
          end

          it 'pings timestamps after connect' do
            client = client_factory.build(:welcome)

            previous_stamp = 0

            3.times do
              ping = client.receive_parsed

              current_stamp = ping[:message]

              assert_equal ping[:type], 'ping'
              assert_kind_of Fixnum, current_stamp
              refute_operator previous_stamp, :>=, current_stamp

              previous_stamp = current_stamp
            end
          end
        end

        describe 'subscribtions cases' do
          before do
            @client = client_factory.build(:ping, :welcome)
          end

          it 'proxies subscription request and confirmation' do
            channel = 'JustChannel'

            subscribe_request = { command: 'subscribe', identifier: { channel: channel }.to_json }.to_json

            @client.send(subscribe_request)

            subscription_confirmation = { identifier: { channel: channel }.to_json, type: 'confirm_subscription' }.to_json

            assert_equal subscription_confirmation, @client.receive
          end

          it 'proxies trasmissions' do
            channel = 'TransmitSubscriptionChannel'

            subscribe_request = { command: 'subscribe', identifier: { channel: channel }.to_json }.to_json

            @client.send(subscribe_request)

            transmission = { identifier: { channel: channel }.to_json, message: 'hello' }.to_json

            assert_equal transmission, @client.receive

            subscription_confirmation = { identifier: { channel: channel }.to_json, type: 'confirm_subscription' }.to_json

            assert_equal subscription_confirmation, @client.receive
          end
        end
      end
    end
  end
end
