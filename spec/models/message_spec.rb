require 'spec_helper'

describe Message do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:message)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :channel_id }
    it { should validate_presence_of :data }
  end

  describe 'relationships' do
    it { should belong_to :channel }
    it { should have_many(:consumers).through(:consumer_messages) }
  end
end
