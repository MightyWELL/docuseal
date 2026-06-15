# frozen_string_literal: true

# MightyWELL fork: per-user document isolation.
# A non-admin "member" (editor role) may only see the templates and submissions
# they authored/created. An admin sees everything in the account.
describe 'Per-user document isolation' do
  let(:account) { create(:account) }
  let(:admin)  { create(:user, account:, role: User::ADMIN_ROLE) }
  let(:chas)   { create(:user, account:, role: 'editor') }
  let(:other)  { create(:user, account:, role: 'editor') }

  describe 'GET /api/templates' do
    it 'shows a member only the templates they authored' do
      mine = create(:template, account:, author: chas)
      create(:template, account:, author: other)
      create(:template, account:, author: admin)

      get '/api/templates', headers: { 'x-auth-token': chas.access_token.token }

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body['data'].pluck('id')
      expect(ids).to contain_exactly(mine.id)
    end

    it 'shows an admin every template in the account' do
      t1 = create(:template, account:, author: chas)
      t2 = create(:template, account:, author: other)
      t3 = create(:template, account:, author: admin)

      get '/api/templates', headers: { 'x-auth-token': admin.access_token.token }

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body['data'].pluck('id')
      expect(ids).to contain_exactly(t1.id, t2.id, t3.id)
    end
  end

  describe 'GET /api/submissions' do
    it 'shows a member only the submissions they created' do
      mine = create(:submission, :with_submitters,
                    template: create(:template, account:, author: chas), created_by_user: chas)
      create(:submission, :with_submitters,
             template: create(:template, account:, author: other), created_by_user: other)

      get '/api/submissions', headers: { 'x-auth-token': chas.access_token.token }

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body['data'].pluck('id')
      expect(ids).to contain_exactly(mine.id)
    end

    it 'shows an admin every submission in the account' do
      s1 = create(:submission, :with_submitters,
                  template: create(:template, account:, author: chas), created_by_user: chas)
      s2 = create(:submission, :with_submitters,
                  template: create(:template, account:, author: other), created_by_user: other)

      get '/api/submissions', headers: { 'x-auth-token': admin.access_token.token }

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body['data'].pluck('id')
      expect(ids).to contain_exactly(s1.id, s2.id)
    end
  end

  describe 'authorization rules (Ability)' do
    it 'lets a member create their own templates and submissions' do
      ability = Ability.new(chas)
      expect(ability.can?(:create, Template)).to be(true)
      expect(ability.can?(:create, Submission)).to be(true)
    end

    it 'lets a member read their own template but not another member\'s' do
      mine = create(:template, account:, author: chas)
      theirs = create(:template, account:, author: other)
      ability = Ability.new(chas)

      expect(ability.can?(:read, mine)).to be(true)
      expect(ability.can?(:read, theirs)).to be(false)
    end

    it 'does not let a member manage users or account settings' do
      ability = Ability.new(chas)
      expect(ability.can?(:manage, User)).to be(false)
      expect(ability.can?(:update, account)).to be(false)
    end
  end

  describe 'GET /api/submissions/:id' do
    it "forbids a member from viewing another member's submission" do
      theirs = create(:submission, :with_submitters,
                      template: create(:template, account:, author: other), created_by_user: other)

      get "/api/submissions/#{theirs.id}", headers: { 'x-auth-token': chas.access_token.token }

      expect(response).to have_http_status(:forbidden)
    end

    it 'lets an admin view any submission' do
      theirs = create(:submission, :with_submitters,
                      template: create(:template, account:, author: other), created_by_user: other)

      get "/api/submissions/#{theirs.id}", headers: { 'x-auth-token': admin.access_token.token }

      expect(response).to have_http_status(:ok)
    end
  end
end
