# frozen_string_literal: true

require_relative "./regexes"

module Harri
  module Collector
    # This function gathers all of the lines describing an error that involves an
    # unused import.
    #
    # An error involving unused imports could look something like this:
    #
    #   src/Module/TypeGenerator/Generate.hs:31:1: error: [-Wunused-imports, -Werror=unused-imports]
    #       The import of ‘Alpha.Beta.Status’ is redundant
    #         except perhaps to import instances from ‘Alpha.Beta.Status’
    #       To import instances alone, use: import Alpha.Beta.Status()
    #      |
    #   31 | import Alpha.Beta.Status
    #      | ^^^^^^^^^^^^^^^^^^^^^^^^
    #
    # That will occur when an entire module is redundant. If specific imports
    # from within a module are redundant, the error could look something like
    # this:
    #
    #   src/Module/TypeGenerator/OtherGenerator.hs:31:1: error: [-Wunused-imports, -Werror=unused-imports]
    #       The import of ‘RedundantImport,
    #                      AnotherRedundantImport, unusedFunction’
    #       from module ‘Alpha.Beta.Status.Types’ is redundant
    #      |
    #   31 | import Alpha.Beta.Status.Types ( ImportantImport, RedundantImport, UsedImport, AnotherRedundantImport, unusedFunction,)
    #      | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    #
    # Note that the first line always contains the name of the file, the line
    # number (and column number) where it occurs, and an optional error marker.
    # What follows is a textual description of the error, followed by a preview
    # of the source where it occurs. This function will capture all of these
    # lines.
    #
    # For completion's sake, here's an example of an unrelated error:
    #
    #   src/Module/TypeGenerator/Generate.hs:712:14: error:
    #       Not in scope: type constructor or class ‘Foo’
    #       |
    #   712 |   doSomething @Foo
    #       |
    #
    # This function will filter out any errors that are not related to unused
    # imports.
    def self.gather_unused_import_errors(text)
      dealing_with_unused_import = false
      unused_import_errors = []
      current_error = []

      text.each_line do |line|
        if is_start_of_an_error? line
          # We've encountered an error, so add the prior error lines (if there were
          # any) to our collection.
          if !current_error.empty?
            unused_import_errors << current_error
            current_error = []
          end

          # Keep track of whether or not we're dealing with an unused import.
          # This is useful to know if we need to capture this and subsequent lines.
          dealing_with_unused_import = is_unused_import_error? line
        end

        # If we're _not_ dealing with an unused import, continue to the next
        # iteration.
        next if !dealing_with_unused_import

        # Otherwise, add the line to our current list of error lines.
        current_error << line
      end

      # We've processed all of the lines; make sure to add the prior error lines
      # (if there were any) to our collection.
      if !current_error.empty?
        unused_import_errors << current_error
      end

      unused_import_errors
    end

    # Determines if the provided line is the beginning of a new error.
    def self.is_start_of_an_error?(line)
      line =~ Harri::Regexes::START_ERROR_REGEX
    end

    # Determines if the provided line is the beginning of an "unused import"
    # error.
    def self.is_unused_import_error?(line)
      line =~ Harri::Regexes::UNUSED_IMPORT_ERROR_REGEX
    end
  end
end
