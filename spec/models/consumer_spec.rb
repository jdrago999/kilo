require 'spec_helper'

describe Consumer do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:consumer)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :channel_id }
    it { should validate_presence_of :user_id }
    it { should validate_uniqueness_of(:user_id).scoped_to(:channel_id) }
  end

  describe 'relationships' do
    it { should have_many :channel_messages }
    it { should have_many(:messages).through(:channel_messages) }
  end
end
