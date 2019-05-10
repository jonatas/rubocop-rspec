RSpec.describe RuboCop::Cop::RSpec::LeakyConstantDeclaration do
  subject(:cop) { described_class.new }

  describe 'constant assignment' do
    it 'flags inside an example group' do
      bad_code = <<-RUBY
        describe MyClass do
          CONSTANT = 'is not allowed'.freeze
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub class or constant instead of declaring explicitly.
          it { expect(CONSTANT).to match /allowed/ }
        end
      RUBY
      expect_offense(bad_code)
    end

    it 'flags inside shared example group' do
      bad_code = <<-RUBY
        RSpec.shared_examples 'my shared example' do
          CONSTANT = 'is not allowed'.freeze
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub class or constant instead of declaring explicitly.
          it { expect(CONSTANT).to match /allowed/ }
        end
      RUBY
      expect_offense(bad_code)
    end

    it 'flags inside an example' do
      bad_code = <<-RUBY
        describe MyClass do
          specify do
            CONSTANT = 'is not allowed'.freeze
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub class or constant instead of declaring explicitly.
            expect(CONSTANT).to match /allowed/
          end
        end
      RUBY
      expect_offense(bad_code)
    end
  end

  describe 'class defined' do
    it 'flags inside an example group' do
      bad_code = <<-RUBY
        describe MyClass do
          class MyDummyClass < described_class
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub class or constant instead of declaring explicitly.
          end
          it { expect(MyDummyClass.new).to be_kind_of(described_class) }
        end
      RUBY
      expect_offense(bad_code)
    end

    it 'ignores anonymous classes' do
      fair_code = <<-RUBY
        describe MyClass do
          let(:dummy_playbook) do
            Class.new do
              def method
              end
            end
          end
         end
      RUBY
      expect_no_offenses(fair_code)
    end

    it 'flags namespaced class' do
      bad_code = <<-RUBY
        describe MyClass do
          class MyModule::AnotherModule::MyClass
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Stub class or constant instead of declaring explicitly.
          end
          it { expect(MyModule::AnotherModule::MyClass).to be_a(MyModule::AnotherModule::MyClass) }
        end
      RUBY
      expect_offense(bad_code)
    end
  end

  describe 'module defined' do
    it 'flags inside an example group' do
      bad_code = <<-RUBY
        describe MyClass do
          module MyModule
          ^^^^^^^^^^^^^^^ Stub class or constant instead of declaring explicitly.
          end
          it { expect(MyModule::ModuleClass.new).to be_kind_of(MyModule::ModuleClass) }
        end
      RUBY
      expect_offense(bad_code)
    end
  end
end
