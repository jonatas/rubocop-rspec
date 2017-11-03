# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ContextDescription, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    rubocop_config = {
      'RSpec/ContextDescription' => { 'Prefix' => %w[when with] }
    }
    RuboCop::Config.new(rubocop_config)
  end

  context 'when not starting with a whitelisted word' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        context 'the display name not present' do
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ block descriptions should always start with 'when' or 'with'
          it { expect(true).to be_truthy }
        end
      RUBY
    end
  end

  context 'when using a whitelisted word' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        context 'when start with when' do
          it { expect(true).to be_truthy }
        end
      RUBY
    end
  end
end
