# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # @example
      #   # bad
      #   context 'the display name not present' do
      #     ...
      #   end
      #
      #   # good
      #   context 'when the display name is not present' do
      #     ...
      #   end
      class ContextDescription < Cop
        MSG = 'block descriptions should always start with %s'.freeze

        def_node_matcher :context_description, <<-PATTERN
          (block (send nil? :context $(...)) args ...)
        PATTERN

        def on_block(node)
          description_node = context_description(node)
          return unless description_node
          return if good_prefix?(description_node)
          add_offense(description_node, location: :expression, message: message)
        end

        private

        def good_prefix?(node)
          node.children[0].match(prefixes_regexp)
        end

        def prefixes_regexp
          @prefixes_regexp ||= begin
            Regexp.union(cop_config['Prefix'].map { |prefix| /#{prefix}\b/ })
          end
        end

        def message
          @message ||= begin
            quoted_words = cop_config['Prefix'].map { |word| "'#{word}'" }
            format(MSG, join_to_sentence(quoted_words))
          end
        end

        def join_to_sentence(words_list)
          return nil unless words_list
          return words_list[0] if words_list.length == 1
          "#{words_list[0...-1].join(', ')} or #{words_list[-1]}"
        end
      end
    end
  end
end
