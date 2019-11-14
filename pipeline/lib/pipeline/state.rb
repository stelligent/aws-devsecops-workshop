# frozen_string_literal: true

require 'aws-sdk'
require 'json'

module Pipeline
  # Class for handling pipeline state
  class State
    def self.store(namespace: 'global', key: '', value: '')
      storage = grab_pipeline_store
      storage[namespace] ||= {}
      storage[namespace][key] = value
      write_pipeline_store(storage)
    end

    def self.retrieve(namespace, key)
      storage = grab_pipeline_store
      namespace_store = storage[namespace]
      namespace_store[key] unless namespace_store.nil?
    end

    def self.grab_pipeline_store
      JSON.parse(File.read('pipeline-data.json'))
    rescue Errno::ENOENT
      write_pipeline_store
    end

    def self.write_pipeline_store(data = {})
      File.write('pipeline-data.json', data.to_json)
      data
    end
  end
end
