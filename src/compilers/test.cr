module Mint
  class Compiler

    def _compile(node : Ast::Test) : String
      name =
        compile node.name

      location =
        node.location.to_json

      raw_expression = node.expression

      expression = _wrap_code_with_location_throw(
        _compile_test(raw_expression),
        node.location
      )

      puts "DEBUG : test.cr : #{expression}"

      "{ name: #{name}, location: [#{location}], proc: (constants) => { return #{expression} } }"
    end
  end
end
