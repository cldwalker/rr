require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "any_instance_of" do
  it "applies to instances instantiated before the Double expection was created" do
    subject_class = Class.new
    subject = subject_class.new
    stub.any_instance_of(subject_class) do |o|
      o.to_s {"Subject is stubbed"}
    end
    subject.to_s.should == "Subject is stubbed"
  end
end
