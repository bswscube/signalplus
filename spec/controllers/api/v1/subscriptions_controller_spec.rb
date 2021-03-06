require 'rails_helper'
require 'shared/stripe'

describe Api::V1::SubscriptionsController, type: :controller do
  include_context 'stripe setup'

  let(:params) { {} }

  before do
    # Assume authenticated
    allow(controller).to receive(:authenticate_user!)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'POST create' do
    before do
      params.merge!(
        email: 'test+1234@example.com',
        subscription_plan_id: basic_plan.id,
        stripe_token: stripe_token,
      )
    end

    context 'a valid response' do
      it 'responds with a 200' do
        post :create, params: params
        expect(response).to be_ok
      end

      it 'creates a subscription' do
        expect {
          post :create, params: params
        }.to change {
          user.brand.reload.subscription.try(:persisted?)
        }.from(nil).to(true)
      end

      it 'changes the email of the user' do
        og_email = user.email
        expect {
          post :create, params: params
        }.to change {
          user.reload.email
        }.from(og_email).to('test+1234@example.com')
      end
    end

    context 'an invalid request' do
      before { post :create, params: params.merge(subscription_plan_id: admin_plan.id) }

      it 'responds with a 422' do
        expect(response.status).to eq(422)
      end

      it 'responds with an error message' do
        response_body = JSON.parse(response.body).with_indifferent_access
        expect(response_body[:message]).to eq('That is an invalid plan.')
      end
    end
  end

  describe 'PUT update' do
    include_context 'brand already subscribed to plan'

    let(:params) { { id: subscription.id, subscription_plan_id: basic_plan.id } }

    context 'not over plan limit' do
      before do
        allow_any_instance_of(Subscription)
          .to receive(:monthly_response_count).and_return(4999)
      end

      it 'should return a 200' do
        put :update, params: params
        expect(response.status).to eq(200)
      end
    end

    context 'over plan limit' do
      before do
        allow_any_instance_of(Subscription)
          .to receive(:monthly_response_count).and_return(5001)
      end

      it 'should return a 422' do
        put :update, params: params
        expect(response.status).to eq(422)
      end
    end

    context 'an trying to upgrade to the admin plan' do
      before { put :update, params: params.merge(subscription_plan_id: admin_plan.id) }

      it 'responds with a 422' do
        expect(response.status).to eq(422)
      end
    end
  end
end
