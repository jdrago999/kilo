require 'spec_helper'

describe User do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:user)).to be_valid
  end

  describe 'validations' do
    it { should have_secure_password }
    it { should validate_presence_of :username }
    it { should validate_uniqueness_of :username }
  end

  describe 'relationships' do
    it { should have_many(:vhosts).through(:vhost_users) }
  end

  describe '#generate_token' do
    before do
      @uuid = 'fake-uuid'
      expect(SecureRandom).to receive(:uuid){ @uuid }
    end
    it 'returns a uuid' do
      expect(described_class.new.generate_token).to eq @uuid
    end
  end

end
