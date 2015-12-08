require 'spec_helper'

describe Consumer do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:consumer)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :channel_id }
    it { should validate_presence_of :vhost_user_id }
    it do
      FactoryGirl.create(:consumer)
      should validate_uniqueness_of(:vhost_user_id).scoped_to(:channel_id)
    end
  end

  describe 'relationships' do
    it { should belong_to :channel }
    it { should belong_to :vhost_user }
    it { should have_many :consumer_messages }
    it { should have_many(:messages).through(:consumer_messages) }
  end

  describe '#consume(count=1)' do
    before do
      @consumer = FactoryGirl.create(:consumer)
    end
    context 'when the channel' do
      before do
        @channel = @consumer.channel
      end
      context 'has unclaimed messages' do
        before do
          @messages = FactoryGirl.create_list(:message, 2, channel: @channel)
          @consumer_messages = @consumer.consume # default is 1
        end
        it 'claims up to $count messages by creating consumer_message records' do
          expect(@consumer_messages).to be_an Array
          expect(@consumer_messages.count).to eq 1
        end
        it 'returns the new consumer_messages' do
          @consumer_message = @consumer_messages.first
          expect(@consumer_message).to be_a ConsumerMessage
          expect(@consumer_message.consumer_id).to eq @consumer.id
        end
      end
      context 'has no unclaimed messages' do
        before do
          @consumer_messages = @consumer.consume
        end
        it 'returns an empty array' do
          expect(@consumer_messages).to be_an Array
          expect(@consumer_messages).to be_empty
        end
      end
    end
  end

end
