module Mint
  class Compiler
    def _compile(node : Ast::Operation) : String
      left =
        compile node.left

      right =
        compile node.right

      case node.operator
      when "or"
        "_o(#{left}._0, #{right})"
      when "=="
        "_compare(#{left}, #{right})"
      when "!="
        "!_compare(#{left}, #{right})"
      else
        "#{left} #{node.operator} #{right}"
      end
    end

    def _compile_test(operation : Ast::Operation) : String?
      operator =
        operation.operator

      return unless operator.in?("==", "!=")

      right =
        compile operation.right

      left =
        compile operation.left

      <<-JS
      ((constants) => {
        const context = new TestContext(#{left})
        const right = #{right}

        context.step((subject) => {
          if (#{"!" if operator == "=="}_compare(subject, right)) {
            throw new TestExceptionWithLocation(
              `Assertion failed: ${right} #{operator} ${subject}`,
              [#{operation.location.to_json}]
            )
          }
          return true
        })
        return context
      })(constants)
      JS
    end
  end
end
