# frozen_string_literal: true

require_relative "./regexes"

module Harri
  module Parser
    def self.parse_unused_import_error(lines)
      first_line = lines[0]
      remaining_lines = lines.drop 1

      file = first_line.match(Harri::Regexes::START_ERROR_REGEX)[1]

      error = remaining_lines.map(&:strip).join " "

      redundant_module_match = error.match Harri::Regexes::ENTIRE_MODULE_REDUNDANT_REGEX
      if redundant_module_match
        {
          file: file,
          module: redundant_module_match[1],
          imports: []
        }
      else
        redundant_imports_match = error.match Harri::Regexes::REDUNDANT_IMPORTS_WITHIN_MODULE_REGEX
        {
          file: file,
          module: redundant_imports_match[2],
          imports: redundant_imports_match[1].split(",").map(&:strip)
        }
      end
    end
  end
end
