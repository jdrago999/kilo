require 'spec_helper'

describe ConsumerMessage do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:consumer_message)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :consumer_id }
    it { should validate_presence_of :message_id }
    it do
      FactoryGirl.create(:consumer_message)
      should validate_uniqueness_of(:message_id).scoped_to(:consumer_id)
    end
  end

  describe 'relationships' do
    it { should belong_to :consumer }
    it { should belong_to :message }
  end
end
