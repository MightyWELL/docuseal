# frozen_string_literal: true

# == Schema Information
#
# Table name: email_signatures
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  kind       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  blob_id    :bigint           not null
#
# Indexes
#
#  index_email_signatures_on_account_id_and_email_and_kind  (account_id,email,kind) UNIQUE
#  index_email_signatures_on_blob_id                        (blob_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (blob_id => active_storage_blobs.id)
#
class EmailSignature < ApplicationRecord
  SIGNATURE_KIND = 'signature'
  INITIALS_KIND = 'initials'

  KINDS = [SIGNATURE_KIND, INITIALS_KIND].freeze

  belongs_to :account
  belongs_to :blob, class_name: 'ActiveStorage::Blob'

  validates :kind, inclusion: { in: KINDS }
end
