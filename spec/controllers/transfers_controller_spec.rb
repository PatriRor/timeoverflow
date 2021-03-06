require 'spec_helper'

describe TransfersController do
  let (:test_organization) { Fabricate(:organization)}
  let (:member_admin) { Fabricate(:member, organization: test_organization, manager: true)}
  let (:member_giver) { Fabricate(:member, organization: test_organization) }
  let (:member_taker) { Fabricate(:member, organization: test_organization) }

  describe "POST #create" do
    context "with valid params" do
      context "with an admin user logged" do
        subject { post 'create', transfer: {source: member_giver.account.id, destination: member_taker.account.id, amount: 5} }

        it "creates a new Transfer" do
          login(member_admin.user)

          expect {
            subject
          }.to change(Transfer, :count).by 1
        end

        it "creates two Movements" do
          login(member_admin.user)

          expect {
            subject
          }.to change { Movement.count}.by 2
        end

        it "updates the balance of both accounts" do
          login(member_admin.user)

          expect {
            subject
            member_giver.reload
          }.to change { member_giver.account.balance.to_i }.by -5

          expect {
            subject
            member_taker.reload
          }.to change { member_taker.account.balance.to_i }.by 5

        end
      end

      context "with a regular user logged" do
        subject { post 'create', transfer: {destination: member_taker.account.id, amount: 5} }

        it "creates a new Transfer" do
          login(member_giver.user)

          expect {
            subject
          }.to change(Transfer, :count).by 1
        end

        it "creates two Movements" do
          login(member_giver.user)

          expect {
            subject
          }.to change { Movement.count}.by 2
        end

        it "updates the balance of both accounts" do
          login(member_giver.user)

          expect {
            subject
            member_giver.reload
          }.to change { member_giver.account.balance.to_i }.by -5

          expect {
            subject
            member_taker.reload
          }.to change { member_taker.account.balance.to_i }.by 5

        end
      end
    end

    # context "with valid params" do
    #   context "with an admin user logged" do
    #     it "creates a new Transfer" do
    #       login(member_admin.user)

    #       post 'create', transfer: {source: member_giver.account.id, destination: member_taker.account.id, amount: 5}

    #       expect(Transfer.count).to eq(1)
    #       expect(Movement.count).to eq(2)

    #       member_giver.reload
    #       member_taker.reload
    #       expect(member_giver.account.balance.to_i).to eq(-5)
    #       expect(member_taker.account.balance.to_i).to eq(5)
    #     end
    #   end

    #   context "with a regular user logged" do
    #     it "creates a new Transfer" do
    #       login(member_giver.user)

    #       post 'create', transfer: {destination: member_taker.account.id, amount: 5}

    #       expect(Transfer.count).to eq(1)
    #       expect(Movement.count).to eq(2)

    #       member_giver.reload
    #       member_taker.reload
    #       expect(member_giver.account.balance.to_i).to eq(-5)
    #       expect(member_taker.account.balance.to_i).to eq(5)
    #     end
    #   end
    # end
  end
end
