require 'spec_helper'

describe ExchangeMessage do
  it 'should have a valid factory' do
    expect(FactoryGirl.create(:exchange_message)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :exchange_id }
    it { should validate_presence_of :message_id }
    it do
      FactoryGirl.create(:exchange_message)
      should validate_uniqueness_of(:message_id).scoped_to(:exchange_id)
    end
  end

  describe 'relationships' do
    it { should belong_to :exchange }
    it { should belong_to :message }
  end
end
