module Harri
  module Regexes
    # Intended to capture the first line of an error within GHC's output.
    START_ERROR_REGEX = %r{
      (.*\.hs)  # filename
      :         # literal colon
      \d+       # line number
      :         # literal colon
      \d+       # column number
      :         # literal colon
      \s        # space
      error:.*  # literal "error:" with possible marker
    }x

    # Intended to capture an unused import error within GHC's output.
    UNUSED_IMPORT_ERROR_REGEX = %r{
      .*\.hs                                         # filename
      :                                              # literal colon
      \d+                                            # line number
      :                                              # literal colon
      \d+                                            # column number
      :                                              # literal colon
      \s                                             # space
      error:                                         # literal "error:"
      \s                                             # space
      \[-Wunused-imports,\s-Werror=unused-imports\]  # literal "[-Wunused-imports, -Werror=unused-imports]"
    }x

    # Intended to capture the scenario when an entire module is redundant.
    ENTIRE_MODULE_REDUNDANT_REGEX = /The(?: qualified)? import of ‘(.+)’ is redundant except.*/

    # Intended to capture the scenario when specific imports within a module are redundant.
    REDUNDANT_IMPORTS_WITHIN_MODULE_REGEX = /The import of ‘(.+)’ from module ‘(.+)’ is redundant.*/

    # Intended to capture a full import declaration within a Haskell module.
    def self.import_declaration_regex(module_name)
      %r{
        ^import                           # literal "import"
        \s+                               # one or more spaces
        (?:qualified\s*)?                 # zero or one literal "qualified" with optional space afterwards
        #{Regexp.quote module_name}       # match "import `module_name`" at start of line
        \s*                               # optional space
        (?:qualified\s*)?                 # zero or one literal "qualified" with optional space afterwards
        (?:as\s+[A-Z]+[a-zA-Z0-9.]*\s*)?  # zero or one literal "as `module_name`" with optional space afterwards
        (?:hiding\s*)?                    # zero or one literal "hiding" with optional space afterwards
        (?:(\((?>[^)(]+|\g<1>)*\)))?      # zero or one list of imports (see https://stackoverflow.com/a/35271017)
        \n?                               # zero or one linebreak
      }x
    end

    # Intended to capture a named reference within an import declaration.
    def self.named_reference_regex(reference)
      %r{
        \b#{Regexp.quote reference}\b  # match "`reference`" exactly as a single word
        (?:\s*,?)?                     # zero or one instances of optional space followed by zero or one comma
        \s*                            # optional space
      }x
    end
  end
end
