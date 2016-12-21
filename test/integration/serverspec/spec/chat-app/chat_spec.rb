#!/usr/bin/env ruby

require 'serverspec'
require_relative '../spec_helper'

describe 'Chat Application Installation' do
  # Listening on the correct port
  describe port(80) do
    it { should be_listening }
  end
end
