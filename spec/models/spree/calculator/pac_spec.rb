require 'spec_helper'

describe Spree::Calculator::PAC, :type => :model do
  before do
    @pac = Spree::Calculator::PAC.new
  end

  it_behaves_like "correios calculator"
  
  it "should have a description" do
    expect(Spree::Calculator::PAC.description).to eq("PAC")
  end
  
  context "without a token and password" do
    it "should have a shipping method of :pac" do
      expect(@pac.shipping_method).to eq(:pac)
    end
    
    it "should have a shipping code of 41106" do
      expect(@pac.shipping_code).to eq(41106)
    end
  end

  context "with a token and password" do
    before do
      @pac.preferred_token = "some token"
      @pac.preferred_password = "some password"
    end
    
    it "should have a shipping method of :pac_com_contrato" do
      expect(@pac.shipping_method).to eq(:pac_com_contrato)
    end
    
    it "should have a shipping code of 41068" do
      expect(@pac.shipping_code).to eq(41068)
    end
  end
end
