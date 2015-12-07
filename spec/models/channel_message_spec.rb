require 'spec_helper'

describe ChannelMessage do
  it 'should have a valid factory' do
    expect(FactoryGirl.create(:channel_message)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :channel_id }
    it { should validate_presence_of :message_id }
    it do
      FactoryGirl.create(:channel_message)
      should validate_uniqueness_of(:message_id).scoped_to(:channel_id)
    end
  end

  describe 'relationships' do
    it { should belong_to :channel }
    it { should belong_to :message }
  end
end
