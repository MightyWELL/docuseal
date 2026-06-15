# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      admin_abilities(user)
    else
      member_abilities(user)
    end

    # Self-owned resources — available to every role.
    can :manage, EncryptedUserConfig, user_id: user.id
    can :manage, UserConfig, user_id: user.id
    can :manage, AccessToken, user_id: user.id
    can :manage, McpToken, user_id: user.id
    can :manage, :mcp
  end

  private

  # Account-wide access — unchanged from upstream DocuSeal.
  def admin_abilities(user)
    can %i[read create update], Template, Abilities::TemplateConditions.collection(user) do |template|
      Abilities::TemplateConditions.entity(template, user:, ability: 'manage')
    end

    can :destroy, Template, account_id: user.account_id
    can :manage, TemplateFolder, account_id: user.account_id
    can :manage, TemplateSharing, template: { account_id: user.account_id }
    can :manage, Submission, account_id: user.account_id
    can :manage, Submitter, account_id: user.account_id
    can :manage, User, account_id: user.account_id
    can :manage, EncryptedConfig, account_id: user.account_id
    can :manage, AccountConfig, account_id: user.account_id
    can :manage, Account, id: user.account_id
    can :manage, WebhookUrl, account_id: user.account_id
  end

  # MightyWELL fork: a member only sees/manages the documents they authored.
  # TemplateConditions.collection/entity are author-scoped for non-admins, so the
  # Template rule is shared; ownership scoping for submissions is by created_by_user_id.
  def member_abilities(user)
    can %i[read create update], Template, Abilities::TemplateConditions.collection(user) do |template|
      Abilities::TemplateConditions.entity(template, user:, ability: 'manage')
    end

    can :destroy, Template, account_id: user.account_id, author_id: user.id
    can :manage, TemplateFolder, account_id: user.account_id, author_id: user.id
    can :manage, Submission, account_id: user.account_id, created_by_user_id: user.id
    can :manage, Submitter, submission: { account_id: user.account_id, created_by_user_id: user.id }
    can :read, Account, id: user.account_id
  end
end
