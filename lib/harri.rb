# frozen_string_literal: true

require_relative "harri/collector"
require_relative "harri/parser"
require_relative "harri/processor"
require_relative "harri/version"

module Harri
  class Error < StandardError; end

  # Parses the unused import errors from a log. This will return something
  # that looks like this:
  #
  # ```
  #   [
  #     {
  #       file:    # the filename where the error is occurring
  #       module:  # the involved module name
  #       imports: # the list of unused imports (if empty, the entire module is
  #                  redundant)
  #     }
  #   ]
  # ```
  def self.parse_unused_import_errors_from_log(log_contents)
    errors = Harri::Collector.gather_unused_import_errors log_contents
    errors.map do |error|
      Harri::Parser.parse_unused_import_error error
    end
  end

  # Removes the redundant imports from a string.
  def self.remove_unused_imports(text, import_info)
    Harri::Processor.remove_imports text, import_info
  end
end
