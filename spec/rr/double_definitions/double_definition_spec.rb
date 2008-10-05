require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinition do
      attr_reader :subject, :double_injection, :double, :definition
      class << self
        define_method("DoubleDefinition where #double_definition_creator is a Reimplementation") do
          before do
            definition.double_definition_creator.implementation_strategy.class.should == Strategies::Implementation::Reimplementation
            call_double_injection
          end
        end

        define_method("DoubleDefinition where #double_definition_creator is a Proxy") do
          before do
#            definition.implemented_by_original_method
            definition.double_definition_creator.proxy
            definition.double_definition_creator.implementation_strategy.class.should == Strategies::Implementation::Proxy
            call_double_injection
          end
        end
      end

      it_should_behave_like "Swapped Space"

      before do
        @subject = Object.new
        add_original_method
        @double_injection = Space.instance.double_injection(subject, :foobar)
        @double = new_double(double_injection)
        @definition = double.definition
      end

      def add_original_method
        def subject.foobar(a, b)
          :original_return_value
        end
      end

      describe "#with" do
        class << self
          define_method "#with" do
            it "returns DoubleDefinition" do
              definition.with(1).should === definition
            end

            it "sets an ArgumentEqualityExpectation" do
              definition.should be_exact_match(1, 2)
              definition.should_not be_exact_match(2)
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with(1, 2) do |*args|
            actual_args = args
            :new_return_value
          end
          subject.foobar(1, 2)
          @return_value = subject.foobar(1, 2)
          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#with"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [1, 2]
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#with"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#with_any_args" do
        class << self
          define_method "#with_any_args" do
            it "returns DoubleDefinition" do
              definition.with_no_args.should === definition
            end

            it "sets an AnyArgumentExpectation" do
              definition.should_not be_exact_match(1)
              definition.should be_wildcard_match(1)
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with_any_args do |*args|
            actual_args = args
            :new_return_value
          end
          @return_value = subject.foobar(1, 2)
          @args = actual_args
        end

        describe "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#with_any_args"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [1, 2]
          end
        end

        describe "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#with_any_args"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#with_no_args" do
        class << self
          define_method "#with_no_args" do
            it "returns DoubleDefinition" do
              definition.with_no_args.should === definition
            end

            it "sets an ArgumentEqualityExpectation with no arguments" do
              definition.argument_expectation.should == Expectations::ArgumentEqualityExpectation.new()
            end
          end
        end

        def add_original_method
          def subject.foobar()
            :original_return_value
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with_no_args do |*args|
            actual_args = args
            :new_return_value
          end
          @return_value = subject.foobar
          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#with_no_args"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == []
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#with_no_args"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#never" do
        it "returns DoubleDefinition" do
          definition.never.should === definition
        end

        it "sets up a Times Called Expectation with 0" do
          definition.with_any_args
          definition.never
          lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
        end

        it "sets return value when block passed in" do
          definition.with_any_args.never
          lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
        end
      end

      describe "#once" do
        class << self
          define_method "#once" do
            it "returns DoubleDefinition" do
              definition.once.should === definition
            end

            it "sets up a Times Called Expectation with 1" do
              lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with_any_args.once do |*args|
            actual_args = args
            :new_return_value
          end
          @return_value = subject.foobar(1, 2)
          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#once"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [1, 2]
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#once"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#twice" do
        class << self
          define_method "#twice" do
            it "returns DoubleDefinition" do
              definition.twice.should === definition
            end

            it "sets up a Times Called Expectation with 2" do
              definition.twice.with_any_args
              lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with_any_args.twice do |*args|
            actual_args = args
            :new_return_value
          end
          subject.foobar(1, 2)
          @return_value = subject.foobar(1, 2)
          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#twice"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [1, 2]
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#twice"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#at_least" do
        class << self
          define_method "#at_least" do
            it "returns DoubleDefinition" do
              definition.with_any_args.at_least(2).should === definition
            end

            it "sets up a Times Called Expectation with 1" do
              definition.times_matcher.should == TimesCalledMatchers::AtLeastMatcher.new(2)
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with_any_args.at_least(2) do |*args|
            actual_args = args
            :new_return_value
          end
          subject.foobar(1, 2)
          @return_value = subject.foobar(1, 2)
          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#at_least"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [1, 2]
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#at_least"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#at_most" do
        class << self
          define_method "#at_most" do
            it "returns DoubleDefinition" do
              definition.with_any_args.at_most(2).should === definition
            end

            it "sets up a Times Called Expectation with 1" do
              lambda do
                subject.foobar
              end.should raise_error(Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected at most 2 times.")
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with_any_args.at_most(2) do |*args|
            actual_args = args
            :new_return_value
          end
          subject.foobar(1, 2)
          @return_value = subject.foobar(1, 2)
          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#at_most"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [1, 2]
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#at_most"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#times" do
        class << self
          define_method "#times" do
            it "returns DoubleDefinition" do
              definition.times(3).should === definition
            end

            it "sets up a Times Called Expectation with passed in times" do
              lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with(1, 2).times(3) do |*args|
            actual_args = args
            :new_return_value
          end
          subject.foobar(1, 2)
          subject.foobar(1, 2)
          @return_value = subject.foobar(1, 2)
          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#times"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [1, 2]
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#times"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#any_number_of_times" do
        class << self
          define_method "#any_number_of_times" do
            it "returns DoubleDefinition" do
              definition.any_number_of_times.should === definition
            end

            it "sets up a Times Called Expectation with AnyTimes matcher" do
              definition.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with(1, 2).any_number_of_times do |*args|
            actual_args = args
            :new_return_value
          end
          subject.foobar(1, 2)
          @return_value = subject.foobar(1, 2)
          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#any_number_of_times"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [1, 2]
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#any_number_of_times"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#ordered" do
        class << self
          define_method "#ordered" do
            it "adds itself to the ordered doubles list" do
              definition.ordered
              Space.instance.ordered_doubles.should include(double)
            end

            it "does not double_injection add itself" do
              definition.ordered
              Space.instance.ordered_doubles.should == [double]
            end

            it "sets ordered? to true" do
              definition.should be_ordered
            end

            it "raises error when there is no Double" do
              definition.double = nil
              lambda do
                definition.ordered
              end.should raise_error(
                Errors::DoubleDefinitionError,
                "Double Definitions must have a dedicated Double to be ordered. " <<
                "For example, using instance_of does not allow ordered to be used. " <<
                "proxy the class's #new method instead."
              )
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with(1, 2).once.ordered do |*args|
            actual_args = args
            :new_return_value
          end
          @return_value = subject.foobar(1, 2)
          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#ordered"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [1, 2]
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#ordered"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#ordered?" do
        it "defaults to false" do
          definition.should_not be_ordered
        end
      end

      describe "#yields" do
        class << self
          define_method "#yields" do
            it "returns DoubleDefinition" do
              definition.yields(:baz).should === definition
            end

            it "yields the passed in argument to the call block when there is a no returns value set" do
              @passed_in_block_arg.should == :baz
            end
          end
        end

        def call_double_injection
          actual_args = nil
          definition.with(1, 2).once.yields(:baz) do |*args|
            actual_args = args
            :new_return_value
          end
          passed_in_block_arg = nil
          @return_value = subject.foobar(1, 2) do |arg|
            passed_in_block_arg = arg
          end
          @passed_in_block_arg = passed_in_block_arg

          @args = actual_args
        end

        context "with returns block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Reimplementation"
          send "#yields"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.length.should == 3
            @args[0..1].should == [1, 2]
            @args[2].should be_instance_of(Proc)
          end
        end

        context "with after_call block_callback_strategy" do
          send "DoubleDefinition where #double_definition_creator is a Proxy"
          send "#yields"

          it "sets return value when block passed in" do
            @return_value.should == :new_return_value
            @args.should == [:original_return_value]
          end
        end
      end

      describe "#after_call" do
        it "returns DoubleDefinition" do
          definition.after_call {}.should === definition
        end

        it "sends return value of Double implementation to after_call" do
          return_value = {}
          definition.with_any_args.returns(return_value).after_call do |value|
            value[:foo] = :bar
            value
          end

          actual_value = subject.foobar
          actual_value.should === return_value
          actual_value.should == {:foo => :bar}
        end

        it "receives the return value in the after_call callback" do
          return_value = :returns_value
          definition.with_any_args.returns(return_value).after_call do |value|
            :after_call_proc
          end

          actual_value = subject.foobar
          actual_value.should == :after_call_proc
        end

        it "allows after_call to mock the return value" do
          return_value = Object.new
          definition.with_any_args.returns(return_value).after_call do |value|
            mock(value).inner_method(1) {:baz}
            value
          end

          subject.foobar.inner_method(1).should == :baz
        end

        it "raises an error when not passed a block" do
          lambda do
            definition.after_call
          end.should raise_error(ArgumentError, "after_call expects a block")
        end
      end

      describe "#returns" do
        it "returns DoubleDefinition" do
          definition.returns {:baz}.should === definition
          definition.returns(:baz).should === definition
        end

        it "sets the value of the method when passed a block" do
          definition.with_any_args.returns {:baz}
          subject.foobar.should == :baz
        end

        it "sets the value of the method when passed an argument" do
          definition.returns(:baz).with_no_args
          subject.foobar.should == :baz
        end

        it "returns false when passed false" do
          definition.returns(false).with_any_args
          subject.foobar.should == false
        end

        it "raises an error when both argument and block is passed in" do
          lambda do
            definition.returns(:baz) {:another}
          end.should raise_error(ArgumentError, "returns cannot accept both an argument and a block")
        end
      end

      describe "#implemented_by" do
        it "returns the DoubleDefinition" do
          definition.implemented_by(lambda{:baz}).should === definition
        end

        it "sets the implementation to the passed in lambda" do
          definition.implemented_by(lambda{:baz}).with_no_args
          subject.foobar.should == :baz
        end

        it "sets the implementation to the passed in method" do
          def subject.foobar(a, b)
            [b, a]
          end
          definition.implemented_by(subject.method(:foobar))
          subject.foobar(1, 2).should == [2, 1]
        end
      end

      describe "#exact_match?" do
        it "returns false when no expectation set" do
          definition.should_not be_exact_match()
          definition.should_not be_exact_match(nil)
          definition.should_not be_exact_match(Object.new)
          definition.should_not be_exact_match(1, 2, 3)
        end

        it "returns false when arguments are not an exact match" do
          definition.with(1, 2, 3)
          definition.should_not be_exact_match(1, 2)
          definition.should_not be_exact_match(1)
          definition.should_not be_exact_match()
          definition.should_not be_exact_match("does not match")
        end

        it "returns true when arguments are an exact match" do
          definition.with(1, 2, 3)
          definition.should be_exact_match(1, 2, 3)
        end
      end

      describe "#wildcard_match?" do
        it "returns false when no expectation set" do
          definition.should_not be_wildcard_match()
          definition.should_not be_wildcard_match(nil)
          definition.should_not be_wildcard_match(Object.new)
          definition.should_not be_wildcard_match(1, 2, 3)
        end

        it "returns true when arguments are an exact match" do
          definition.with(1, 2, 3)
          definition.should be_wildcard_match(1, 2, 3)
          definition.should_not be_wildcard_match(1, 2)
          definition.should_not be_wildcard_match(1)
          definition.should_not be_wildcard_match()
          definition.should_not be_wildcard_match("does not match")
        end

        it "returns true when with_any_args" do
          definition.with_any_args

          definition.should be_wildcard_match(1, 2, 3)
          definition.should be_wildcard_match(1, 2)
          definition.should be_wildcard_match(1)
          definition.should be_wildcard_match()
          definition.should be_wildcard_match("does not match")
        end
      end

      describe "#terminal?" do
        it "returns true when times_matcher's terminal? is true" do
          definition.once
          definition.times_matcher.should be_terminal
          definition.should be_terminal
        end

        it "returns false when times_matcher's terminal? is false" do
          definition.any_number_of_times
          definition.times_matcher.should_not be_terminal
          definition.should_not be_terminal
        end

        it "returns false when there is not times_matcher" do
          definition.times_matcher.should be_nil
          definition.should_not be_terminal
        end
      end

      describe "#expected_arguments" do
        it "returns argument expectation's expected_arguments when there is a argument expectation" do
          definition.with(1, 2)
          definition.expected_arguments.should == [1, 2]
        end

        it "returns an empty array when there is no argument expectation" do
          definition.argument_expectation.should be_nil
          definition.expected_arguments.should == []
        end
      end

      describe "#verbose" do
        it "sets the verbose? to true" do
          definition.should_not be_verbose
          definition.verbose
          definition.should be_verbose
        end
      end
    end
  end
end