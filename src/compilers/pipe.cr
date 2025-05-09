module Mint
  class Compiler
    def _compile(node : Ast::Pipe) : String
      compile node.call
    end

    def _compile_test(node : Ast::Pipe) : String
      _compile_test node.call
    end
  end
end
