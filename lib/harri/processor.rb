# frozen_string_literal: true

require_relative "./regexes"

module Harri
  module Processor
    def self.remove_imports(text, import_info)
      import_regex = Harri::Regexes.import_declaration_regex import_info[:module]
      match = text.match import_regex

      return text if !match

      if import_info[:imports].empty?
        # There are no imports, so the whole module is redundant.
        text.sub(/^#{Regexp.quote(match[0])}/, "")
      else
        # Filter out specific imports within the module.
        filtered_imports = import_info[:imports].reduce(match[0]) do |result, import|
          reference_regex = Harri::Regexes.named_reference_regex import
          # Filter out the import along with a comma (if present).
          result.sub reference_regex, ""
        end
        text.sub match[0], filtered_imports
      end
    end
  end
end
