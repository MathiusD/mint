module Mint
  class Compiler
    def compile(node : Ast::Block, for_function = false) : String
      node.in?(checked) ? _compile(node, for_function) : ""
    end

    def _compile(node : Ast::Block, for_function = false) : String
      statements =
        node
          .statements
          .select(Ast::Statement)
          .sort_by! { |item| resolve_order.index(item) || -1 }

      if statements.size == 1
        if for_function
          js.return(compile(statements.first, true))
        else
          compile(statements.first, true)
        end
      else
        compiled_statements =
          statements.map { |item| compile item, item == statements.last }

        last =
          compiled_statements.pop

        if for_function
          js.statements(compiled_statements + [js.return(last)])
        else
          if node.async?
            js.asynciif do
              js.statements(compiled_statements + [js.return(last)])
            end
          else
            js.iif do
              js.statements(compiled_statements + [js.return(last)])
            end
          end
        end
      end
    end

    def _compile_test(node : Ast::Block, for_function = false) : String
      statements =
        node
          .statements
          .select(Ast::Statement)
          .sort_by! { |item| resolve_order.index(item) || -1 }

      code = 
      if statements.size == 1
        if for_function
          js.return(_compile_test(statements.first, true))
        else
          _compile_test(statements.first, true)
        end
      else
        current_statement : Ast::Statement
        last = true
        compiled_statements : String = ""

        while statements.size > 0
          current_statement = statements.pop
          current_compiled_statement = _compile_test current_statement, last
          if last
            last = false
            compiled_statements = js.return(current_compiled_statement)
          else
            compiled_statements = js.statements([current_compiled_statement, compiled_statements])
          end
        end

        if for_function
          compiled_statements
        else
          if node.async?
            js.asynciif do
              compiled_statements
            end
          else
            js.iif do
              compiled_statements
            end
          end
        end
      end

      _wrap_code_with_location_throw(code, node.location)
    end
  end
end
