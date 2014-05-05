describe Ggi::Svg do
  [:by, :by_nc_nd, :by_nc_sa, :by_nc, :by_nd, :by_sa, :zero, :publicdomain,
   :poor, :average, :good].each do |m|
    describe "self.#{m.to_s}" do
      it 'should return svg' do
        expect( Ggi::Svg.send(m) ).to match /^<svg.*?\/svg>/
      end
    end
  end
end
