require 'spec_helper'

describe Message do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:message)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :data }
  end

  describe 'relationships' do
    it { should have_many :channel_messages }
    it { should have_many(:channels).through(:channel_messages) }
  end
end
