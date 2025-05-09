module Mint
  class Compiler
    def _compile_test(node : Ast::Node) : String
      _wrap_code_with_location_throw _compile(node), node.location
    end

    def _wrap_code_with_location_throw(code : String?, location : Ast::Node::Location) : String?
      js.iif(
        js.try(
          js.return(code),
          [
            js.catch(
              "error",
              <<-JS
              if (error instanceof TestExceptionWithLocation) {
                throw new TestExceptionWithLocation(
                  error.message,
                  [#{location.to_json}].concat(error.location)
                )
              } else {
                throw new TestExceptionWithLocation(error, [#{location.to_json}])
              }
              JS
            ),
          ],
          ""
        )
      )
    end
  end
end