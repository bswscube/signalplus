class InvoiceSerializer < ActiveModel::Serializer
  attributes :id, :stripe_invoice_id, :amount, :paid_at, :created_at
end
