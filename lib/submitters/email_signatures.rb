# frozen_string_literal: true

module Submitters
  module EmailSignatures
    module_function

    def enabled?(submitter)
      submitter.submission.account.account_configs
               .find_by(key: AccountConfig::SAVE_SIGNATURE_BY_EMAIL_KEY)&.value == true
    end

    def save!(submitter, attachment, kind:)
      return if submitter.email.blank?

      email_signature =
        EmailSignature.find_or_initialize_by(account_id: submitter.submission.account_id,
                                             email: submitter.email,
                                             kind:)

      email_signature.update!(blob_id: attachment.blob_id)

      email_signature
    end

    def find_or_assign_attachment(submitter, kind, attachments = [])
      return if submitter.email.blank?

      email_signature = EmailSignature.find_by(account_id: submitter.submission.account_id,
                                               email: submitter.email,
                                               kind:)

      return unless email_signature

      existing_attachment = attachments.find do |a|
        a.blob_id == email_signature.blob_id && a.record_id == submitter.id && a.record_type == 'Submitter'
      end

      return existing_attachment if existing_attachment

      submitter.attachments_attachments.create_or_find_by!(blob_id: email_signature.blob_id)
    end
  end
end
