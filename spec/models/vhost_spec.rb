require 'spec_helper'

describe Vhost do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:vhost)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end

  describe 'relationships' do
    it { should have_many(:users).through(:vhost_users) }
    it { should have_many :channels }
    it { should have_many :exchanges }
  end
end

