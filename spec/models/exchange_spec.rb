require 'spec_helper'

describe Exchange do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:exchange)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of :vhost_id }
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of(:name).scoped_to(:vhost_id) }

    # XXX: shoulda-matchers complains about this boolean inclusion test, but I don't GAF.
    it { should validate_inclusion_of(:fanout).in_array([true, false]) }
  end

  describe 'relationships' do
    it { should belong_to :vhost }
    it { should have_many :bonds }
    it { should have_many(:channels).through(:bonds) }
  end
end
