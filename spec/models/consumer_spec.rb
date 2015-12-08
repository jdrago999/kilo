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
  end
end
