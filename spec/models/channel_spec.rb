require 'spec_helper'

describe Channel do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:channel)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :vhost_id }
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of(:name).scoped_to(:vhost_id) }
  end

  describe 'relationships' do
    it { should belong_to :vhost }
    it { should have_many :consumers }
  end

  describe '#publish(message_data)' do
    before do
      @channel = FactoryGirl.create(:channel)
    end
    context 'when there are consumers' do
      before do
        @vhost = @channel.vhost
        @vhost_user1 = FactoryGirl.create(:vhost_user, vhost: @vhost)
        @consumer1 = FactoryGirl.create(:consumer, vhost_user: @vhost_user1, channel: @channel)
        @vhost_user2 = FactoryGirl.create(:vhost_user, vhost: @vhost)
        @consumer2 = FactoryGirl.create(:consumer, vhost_user: @vhost_user2, channel: @channel)
        @message_data = SecureRandom.hex(32)

        # Publishing returns the id of the consumer the message was assigned to.
        @assigned_consumer_id = @channel.publish(@message_data)
      end
      it 'assigns the message to one of the consumers, at random' do
        expect([@consumer1.id, @consumer2.id]).to include @assigned_consumer_id
        assigned_consumer_id = Consumer.find(@assigned_consumer_id)
        expect(assigned_consumer_id.messages.first.data).to eq @message_data
      end
    end
    context 'when there are no consumers' do
      before do
        @message_data = SecureRandom.hex(32)

        # Publishing returns the id of the consumer the message was assigned to.
        @assigned_consumer_id = @channel.publish(@message_data)
      end
      it 'does not assign the message' do
        expect(@assigned_consumer_id).to be_nil
        expect(Message.all).to be_empty
      end
    end
  end

  describe '#broadcast(message_data)' do
    context 'when there are consumers' do
      it 'assigns the message to all of the consumers, at once'
    end
    context 'when there are no consumers' do
      it 'does not assign the message'
    end
  end
end
