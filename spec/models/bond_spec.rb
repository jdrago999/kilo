require 'spec_helper'

describe Bond do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:bond)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :exchange_id }
    it { should validate_presence_of :channel_id }
    it do
      FactoryGirl.create(:bond)
      should validate_uniqueness_of(:channel_id).scoped_to(:exchange_id)
    end
  end
end
