# frozen_string_literal: true

require_relative "./regexes"

module Harri
  module Processor
    # Removes the redundant imports from a string.
    def self.remove_imports(text, import_info)
      import_regex = Harri::Regexes.import_declaration_regex import_info[:module]
      match = text.match import_regex

      return text if !match

      if import_info[:imports].empty?
        # There are no imports, so the whole module is redundant.
        text.sub(/^#{Regexp.quote(match[0])}/, "")
      else
        module_imports = match[1]
        return text if !module_imports

        # Filter out specific imports within the module.
        filtered_imports = import_info[:imports].reduce(module_imports) do |result, import|
          reference_regex = Harri::Regexes.named_reference_regex import
          result.sub reference_regex, ""
        end
        replaced_imports = match[0].sub module_imports, filtered_imports
        text.sub match[0], replaced_imports
      end
    end
  end
end
