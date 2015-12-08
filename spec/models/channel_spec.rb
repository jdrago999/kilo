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
    it { should have_many :messages }
    it { should have_many(:consumer_messages).through(:consumers) }
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

        # Publish returns the message.
        @message = @channel.publish(@message_data)
      end
      it 'creates the message' do
        expect(@message.channel_id).to eq @channel.id
      end
    end
    context 'when there are no consumers' do
      before do
        @message_data = SecureRandom.hex(32)

        @message = @channel.publish(@message_data)
      end
      it 'still creates the message' do
        expect(@message.channel_id).to eq @channel.id
      end
    end
  end

  describe '#broadcast(message_data)' do
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

        # Broadcast returns the message.
        @message = @channel.broadcast(@message_data)
      end
      it 'assigns the message to all of the consumers, at once' do
        expect(@message).to be_a Message
        expect(@message.channel_id).to eq @channel.id
        expect(@consumer1.messages.first.data).to eq @message_data
        expect(@consumer2.messages.first.data).to eq @message_data
      end
    end
    context 'when there are no consumers' do
      before do
        @message_data = SecureRandom.hex(32)

        # Broadcast returns the message.
        @message = @channel.broadcast(@message_data)
      end
      it 'does not assign the message' do
        expect(@message).to be_nil
      end
    end
  end
end
