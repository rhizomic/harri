# frozen_string_literal: true

require "test_helper"

class TestHarri < Minitest::Test
  def test_parse_unused_import_errors_from_log
    log = %(
src/Module/TypeGenerator/Generate.hs:31:1: error: [-Wunused-imports, -Werror=unused-imports]
    The import of ‘Alpha.Beta.Status’ is redundant
      except perhaps to import instances from ‘Alpha.Beta.Status’
    To import instances alone, use: import Alpha.Beta.Status()
   |
31 | import Alpha.Beta.Status
   | ^^^^^^^^^^^^^^^^^^^^^^^^

src/Module/TypeGenerator/Generate.hs:35:1: error: [-Wunused-imports, -Werror=unused-imports]
    The qualified import of ‘Network.HTTP.Types.Status’ is redundant
      except perhaps to import instances from ‘Network.HTTP.Types.Status’
    To import instances alone, use: import Network.HTTP.Types.Status()
   |
77 | import Network.HTTP.Types.Status qualified as Status
   | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

src/Module/TypeGenerator/Generate.hs:712:14: error:
    Not in scope: type constructor or class ‘Foo’
    |
712 |   doSomething @Foo
    |

src/Module/TypeGenerator/OtherGenerator.hs:31:1: error: [-Wunused-imports, -Werror=unused-imports]
    The import of ‘RedundantImport,
                   AnotherRedundantImport, unusedFunction’
    from module ‘Alpha.Beta.Status.Types’ is redundant
   |
31 | import Alpha.Beta.Status.Types ( ImportantImport, RedundantImport, UsedImport, AnotherRedundantImport, unusedFunction,)
   | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

)
    actual = Harri.parse_unused_import_errors_from_log log
    expected = [
      {
        file: "src/Module/TypeGenerator/Generate.hs",
        module: "Alpha.Beta.Status",
        imports: []
      },
      {
        file: "src/Module/TypeGenerator/Generate.hs",
        module: "Network.HTTP.Types.Status",
        imports: []
      },
      {
        file: "src/Module/TypeGenerator/OtherGenerator.hs",
        module: "Alpha.Beta.Status.Types",
        imports: ["RedundantImport", "AnotherRedundantImport", "unusedFunction"]
      }
    ]

    assert_equal expected, actual
  end

  def test_remove_unused_imports
    text = %(
import Unrelated.Module
import Another.Unrelated.Module
  ( TypeA,
    TypeB,
  )
import Alpha.Beta.Status
import Prelude
import Data.Text.IO qualified as TIO
import Alpha.Beta.Status.Types
  ( ImportantImport,
    RedundantImport,
    UsedImport,
    AnotherRedundantImport,
    unusedFunction,
  )
import Data.Text qualified as T (lines, pack, splitOn, strip, toLower, unpack)
import Some.Other.Module qualified as ReallyImportantModule
).strip

    import_infos = [
      {
        file: "src/Module/TypeGenerator/Generate.hs",
        module: "Alpha.Beta.Status",
        imports: []
      },
      {
        file: "src/Module/TypeGenerator/Generate.hs",
        module: "Alpha.Beta.Status.Types",
        imports: ["RedundantImport", "AnotherRedundantImport", "unusedFunction"]
      },
      {
        file: "src/Module/TypeGenerator/Generate.hs",
        module: "Data.Text.IO",
        imports: []
      },
      {
        file: "src/Module/TypeGenerator/Generate.hs",
        module: "Data.Text",
        imports: ["pack"]
      }
    ]

    actual = import_infos.reduce(text) do |final, import_info|
      Harri.remove_unused_imports final, import_info
    end

    expected = %(
import Unrelated.Module
import Another.Unrelated.Module
  ( TypeA,
    TypeB,
  )
import Prelude
import Alpha.Beta.Status.Types
  ( ImportantImport,
    UsedImport,
    )
import Data.Text qualified as T (lines, splitOn, strip, toLower, unpack)
import Some.Other.Module qualified as ReallyImportantModule
).strip

    assert_equal expected, actual
  end

  def test_import_declaration_regex
    declarations = [
      # Vanilla Haskell
      # https://wiki.haskell.org/Import
      "import Mod",
      "import Mod ()",
      "import Mod (x,y, (+++))",
      "import qualified Mod",
      "import qualified Mod (x,y)",
      "import Mod hiding (x,y,(+++))",
      "import qualified Mod hiding (x,y)",
      "import Mod as Foo",
      "import Mod as Foo (x,y)",
      "import Mod as Foo hiding (x,y)",
      "import qualified Mod as Foo",
      "import qualified Mod as Foo (x,y)",
      "import qualified Mod as Foo hiding (x,y)",

      %(
import Mod
  ( x,
    y,
  )
).strip,

      # ImportQualifiedPost
      # https://downloads.haskell.org/ghc/latest/docs/users_guide/exts/import_qualified_post.html
      "import Mod qualified",
      "import Mod qualified (x,y)",
      "import Mod qualified hiding (x,y)",
      "import Mod qualified as Foo",
      "import Mod qualified as Foo (x,y)",
      "import Mod qualified as Foo hiding (x,y)"
    ]

    regex = Harri::Regexes.import_declaration_regex "Mod"

    declarations.each do |expected|
      actual = expected.match(regex)[0]
      assert_equal expected, actual
    end
  end

  def test_named_reference_regex
    reference = "get"
    reference_regex = Harri::Regexes.named_reference_regex reference

    reference_tests = [
      {
        # leading single line
        original: "import Mod (get, getBy, update)",
        expected: "import Mod (getBy, update)"
      },
      {
        # middle single line
        original: "import Mod (getBy, get, update)",
        expected: "import Mod (getBy, update)"
      },
      {
        # ending single line
        original: "import Mod (getBy, update, get)",
        expected: "import Mod (getBy, update, )"
      },
      {
        # leading multi-line trailing comma
        original: %(
import Mod
  ( get,
    getBy,
    update
  )
        ),
        expected: %(
import Mod
  ( getBy,
    update
  )
        )
      },
      {
        # middle multi-line trailing comma
        original: %(
import Mod
  ( getBy,
    get,
    update
  )
        ),
        expected: %(
import Mod
  ( getBy,
    update
  )
        )
      },
      {
        # ending multi-line trailing comma
        original: %(
import Mod
  ( getBy,
    update,
    get,
  )
        ),
        expected: %(
import Mod
  ( getBy,
    update,
    )
        )
      },
      {
        # leading multi-line leading comma
        original: %(
import Mod
  ( get
  , getBy
  , update
  )
        ),
        expected: %(
import Mod
  ( getBy
  , update
  )
        )
      },
      {
        # middle multi-line leading comma
        original: %(
import Mod
  ( getBy
  , get
  , update
  )
        ),
        expected: %(
import Mod
  ( getBy
  , update
  )
        )
      },
      {
        # ending multi-line leading comma
        original: %(
import Mod
  ( getBy
  , update
  , get
  )
        ),
        expected: %(
import Mod
  ( getBy
  , update
  , )
        )
      }
    ]

    reference_tests.each do |reference_test|
      actual = reference_test[:original].sub reference_regex, ""
      assert_equal reference_test[:expected], actual
    end
  end
end
