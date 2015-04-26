require 'spree/testing_support/factories'
shared_examples_for "correios calculator" do
  before { @calculator = subject.class.new }

  it "has preferences" do
    expect(@calculator.preferences.keys).to include(:zipcode, :declared_value, :receipt_notification, :receive_in_hands, :token, :password)
  end

  it "declared value should default to false" do
     expect(@calculator.preferred_declared_value).to be false
  end

  it "receipt notification should default to false" do
    expect(@calculator.preferred_receipt_notification).to be false
  end

  it "receive in hands should default to false" do
    expect(@calculator.preferred_receive_in_hands).to be false
  end

  it "has not a contract" do
    expect(@calculator).to_not have_contract
  end

  
  it "should have a contract if both token and password are given" do
    @calculator.preferred_token = "some token"
    @calculator.preferred_password = "some password"
    expect(@calculator).to have_contract
  end
  
  context "compute" do
    def get_correios_price_and_value_for(url)
      doc = Nokogiri::XML(open(url))
      price = doc.css("Valor").first.content.sub(/,(\d\d)$/, '.\1').to_f
      prazo = doc.css("PrazoEntrega").first.content.to_i
      return price, prazo
    end
    
    before do
      @order = FactoryGirl.create(:order_with_line_items, line_items_count: 1 , ship_address: FactoryGirl.create(:ship_address, zipcode: '72151613'))
      @calculator.preferred_zipcode = "71939360"
    end
    
    it "should calculate shipping cost and delivery time" do
      if @calculator.class.name != "Spree::Calculator::CorreiosBaseCalculator"
        price, prazo = get_correios_price_and_value_for("http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx?nCdEmpresa=&sDsSenha=&sCepOrigem=71939360&sCepDestino=72151613&nVlPeso=1&nCdFormato=1&nVlComprimento=20&nVlAltura=5&nVlLargura=15&sCdMaoPropria=n&nVlValorDeclarado=0&sCdAvisoRecebimento=n&nCdServico=#{@calculator.shipping_code}&nVlDiametro=0&StrRetorno=xml")
        expect(@calculator.compute_package(@order)).to eq(price)
        expect(@calculator.delivery_time).to eq(prazo)
      end
    end
    
    it "should change price according to declared value" do
      if @calculator.class.name != "Spree::Calculator::CorreiosBaseCalculator"
        price, prazo = get_correios_price_and_value_for("http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx?nCdEmpresa=&sDsSenha=&sCepOrigem=71939360&sCepDestino=72151613&nVlPeso=1&nCdFormato=1&nVlComprimento=20&nVlAltura=5&nVlLargura=15&sCdMaoPropria=n&nVlValorDeclarado=10,00&sCdAvisoRecebimento=n&nCdServico=#{@calculator.shipping_code}&nVlDiametro=0&StrRetorno=xml")

        @calculator.preferred_declared_value = true
        expect(@calculator.compute_package(@order)).to eq(price)
      end
    end
    
    it "should change price according to in hands" do
      if @calculator.class.name != "Spree::Calculator::CorreiosBaseCalculator"
        price, prazo = get_correios_price_and_value_for("http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx?nCdEmpresa=&sDsSenha=&sCepOrigem=71939360&sCepDestino=72151613&nVlPeso=1&nCdFormato=1&nVlComprimento=20&nVlAltura=5&nVlLargura=15&sCdMaoPropria=s&nVlValorDeclarado=0&sCdAvisoRecebimento=n&nCdServico=#{@calculator.shipping_code}&nVlDiametro=0&StrRetorno=xml")

        @calculator.preferred_receive_in_hands = true
        expect(@calculator.compute_package(@order)).to eq(price)
      end
    end

    it "should change price according to receipt notification" do
      if @calculator.class.name != "Spree::Calculator::CorreiosBaseCalculator"
        price, prazo = get_correios_price_and_value_for("http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx?nCdEmpresa=&sDsSenha=&sCepOrigem=71939360&sCepDestino=72151613&nVlPeso=1&nCdFormato=1&nVlComprimento=20&nVlAltura=5&nVlLargura=15&sCdMaoPropria=n&nVlValorDeclarado=0&sCdAvisoRecebimento=s&nCdServico=#{@calculator.shipping_code}&nVlDiametro=0&StrRetorno=xml")

        @calculator.preferred_receipt_notification = true
        expect(@calculator.compute_package(@order)).to eq(price)
      end
    end    
  end
end
