# == Schema Information
#
# Table name: employees
#
#  id            :integer          not null, primary key
#  name          :string(64)       not null
#  surname       :string(64)       not null
#  date_of_birth :date             not null
#  email         :string(64)       not null
#  shirt_size    :integer          default(0)
#  password_hash :string(128)      not null
#  password_salt :string(128)      not null
#  last_login    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe Employee, type: :model do

  let(:employee) {build(:employee)}

  it 'should be valid' do
    employee.valid?
    expect(employee.errors.messages.keys.empty?).to be_truthy
  end

  it 'should validate attributes presence' do
    [
        :name,
        :surname,
        :date_of_birth,
        :email,
        :password_hash,
        :password_salt

    ].each do |attr|
      is_expected.to validate_presence_of(attr)
    end
  end

  it 'invalidates name and surname are' do
    employee.name = '$John12'
    employee.surname = '&Doe34'

    employee.valid?
    expect(employee.errors.messages[:name]).not_to be_nil
    expect(employee.errors.messages[:surname]).not_to be_nil

  end

  describe 'email address' do
    it 'should be valid' do
      employee.valid?
      expect(employee.errors.messages[:email]).to be(nil)
    end

    it 'should be invalid' do
      employee.email = 'john.doegmail.com'
      employee.valid?
      expect(employee.errors.messages[:email]).not_to be(nil)
    end
  end

  describe 'shirt size' do
    it 'should be valid' do
      INIT_VALS[:shirt_sizes].each do |size|
        employee.shirt_size = size
        employee.valid?
        expect(employee.errors.messages[:shirt_size]).to be_nil
      end
    end
  end

  describe 'validates password' do
    it 'should be valid' do
      employee.valid?
      expect(employee.errors.messages[:password]).to be_nil
    end

    it 'should be invalid' do
      password = Proc.new { |length| rand(36**length).to_s(36) }
      {
          less_than_6_chars:    password.call(5),
          greater_than_2_chars: password.call(22),
          invalid_chars:        '_$%^&'

      }.each do |state, example|
        employee.password = example
        employee.valid?
        expect(employee.errors.messages[:password]).not_to be_nil, "failed with \"#{example}\" because it is not #{state.to_s.gsub('_', ' ')}"
      end
    end

    it 'should not be empty' do
      employee.password = nil
      employee.valid?
      expect(employee.errors.messages[:password]).not_to be nil
    end

  end

  # describe 'validates date of birth format' do
  #   it 'should be invalid' do
  #     employee.date_of_birth = 'incorrect format'
  #     employee.valid?
  #     expect(employee.errors.messages[:date_of_birth]).not_to be_nil
  #   end
  # end

  describe '#create_employee' do

    let(:types) { StaffType.all.sample(2) }
    let(:access_levels) { AccessLevel.all.sample(2) }

    it 'assigns default access level' do
      expect(employee.create_employee(types, nil)).to be_truthy
      expect(employee.staff_types.size).to eq 2
      expect(employee.access_levels.pluck(:title).first).to eq 'staff'
    end

    it 'assign given access level' do
      expect(employee.create_employee(types, access_levels)).to be_truthy
      expect(employee.access_levels.size).to eq 2
    end

    it 'triggers #create_password_hash upon save' do
      expect(employee).to respond_to(:create_password_hash)
      employee.save
    end

  end

  it 'creates password_salt and password_hash' do
    employee.password_salt = nil
    employee.password_hash = nil

    employee.create_password_hash
    expect(employee.password_salt).not_to be_nil
    expect(employee.password_hash).not_to be_nil
  end

end
