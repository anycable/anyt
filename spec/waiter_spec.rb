# frozen_string_literal: true

require 'spec_helper'
require 'anycablebility/waiter'

Waiter = Anycablebility::Waiter

describe Waiter do
  describe '.wait' do
    it 'throws Waiter::TimeoutError when timeout is reached' do
      begin
        Waiter.wait(0.5, 0.01) { false }
        fail
      rescue Waiter::TimeoutError
        pass
      end
    end

    it 'waits until callback returns true' do
      start_time = Time.now.to_f
      tick_count = 0

      Waiter.wait(0.5, 0.01) do
        tick_count += 1
        Time.now.to_f - start_time > 0.1
      end

      assert (9..11).include?(tick_count)
    end
  end
end
