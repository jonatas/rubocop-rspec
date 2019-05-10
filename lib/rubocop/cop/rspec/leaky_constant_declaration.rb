module RuboCop
  module Cop
    module RSpec
      # Checks that no class, module, or a constant is declared.
      #
      # Constants, including classes and modules, when declared in a block
      # scope, are defined in global namespace, and leak between examples.
      #
      # @example Constants leak between examples
      #   # bad
      #   describe SomeClass do
      #     OtherClass = Struct.new
      #     CONSTANT_HERE = 'is also denied'
      #   end
      #
      #   # good
      #   # https://relishapp.com/rspec/rspec-mocks/docs/mutating-constants
      #   describe SomeClass do
      #     before do
      #       stub_const('OtherClass', Struct.new)
      #       stub_const('CONSTANT_HERE', 'is also denied')
      #     end
      #   end
      #
      # @example
      #   # bad
      #   describe SomeClass do
      #     class OtherClass < described_class
      #       def do_something
      #       end
      #     end
      #   end
      #
      #   # good
      #   # https://relishapp.com/rspec/rspec-mocks/docs/mutating-constants
      #   describe SomeClass do
      #     before do
      #       fake_class = Class.new(described_class) do
      #                      def do_something
      #                      end
      #                    end
      #       stub_const('OtherClass', fake_class)
      #     end
      #   end
      #
      # @example
      #   # bad
      #   describe SomeClass do
      #     module SomeModule
      #       class SomeClass
      #         def do_something
      #         end
      #       end
      #     end
      #   end
      #
      #   # good
      #   # https://relishapp.com/rspec/rspec-mocks/docs/mutating-constants
      #   describe SomeClass do
      #     before do
      #       fake_class = Class.new(described_class) do
      #         def do_something
      #         end
      #       end
      #       stub_const('SomeModule::SomeClass', fake_class)
      #     end
      #   end
      class LeakyConstantDeclaration < Cop
        MSG = 'Stub class or constant instead of declaring explicitly.'.freeze

        def on_casgn(node)
          return unless inside_describe_block?(node)

          add_offense(node, location: :expression, message: MSG)
        end

        def on_class(node)
          return unless inside_describe_block?(node)

          add_offense(node, location: :expression, message: MSG)
        end

        def on_module(node)
          return unless inside_describe_block?(node)

          add_offense(node, location: :expression, message: MSG)
        end

        private

        def inside_describe_block?(node)
          node.each_ancestor(:block).any?(&method(:in_example_or_shared_group?))
        end

        def_node_search :in_example_or_shared_group?, <<-PATTERN
          (block
            (send #{RSPEC}
              #{(ExampleGroups::ALL + SharedGroups::ALL).node_pattern_union} ...
            ) ...
          )
        PATTERN
      end
    end
  end
end
