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
    it { should have_many :bonds }
    it { should have_many :consumers }
    it { should have_many(:exchanges).through(:bonds) }
  end
end
