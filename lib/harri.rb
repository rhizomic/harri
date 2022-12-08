# frozen_string_literal: true

require_relative "harri/collector"
require_relative "harri/parser"
require_relative "harri/processor"
require_relative "harri/version"

module Harri
  class Error < StandardError; end

  def self.parse_unused_import_errors_from_log(log)
    errors = Harri::Collector.gather_unused_import_errors log
    errors.map do |error|
      Harri::Parser.parse_unused_import_error error
    end
  end

  def self.remove_unused_imports(text, import_info)
    Harri::Processor.remove_imports text, import_info
  end
end
