require 'spec_helper'

describe VhostUser do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:vhost_user)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :vhost_id }
    it { should validate_presence_of :user_id }
    it do
      FactoryGirl.create(:vhost_user)
      should validate_uniqueness_of(:user_id).scoped_to(:vhost_id)
    end
  end

  describe 'relationships' do
    it { should belong_to :vhost }
    it { should belong_to :user }
  end
end

