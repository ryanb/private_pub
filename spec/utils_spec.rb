require "spec_helper"

describe PrivatePub::Utils do
  context "#symbolize_keys" do
    before(:each) do
      @data = { 'key1' => 'value1', 'key2' => { 'nested1' => 'nestedvalue' } }
    end

    it "should change top-level string keys into symbols" do
      data = PrivatePub::Utils.symbolize_keys(@data)
      data[:key1].should == 'value1'
      data.has_key?('key1').should == false
    end

    it "should change nested string keys into symbols" do
      data = PrivatePub::Utils.symbolize_keys(@data)
      data[:key2][:nested1].should == 'nestedvalue'
      data[:key2].has_key?('nested1').should == false
    end
  end
end
