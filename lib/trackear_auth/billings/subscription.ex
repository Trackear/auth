defmodule TrackearAuth.Billings.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pay_subscriptions" do
    field :cancel_url, :string
    field :ends_at, :naive_datetime
    field :name, :string
    field :owner_id, :integer
    field :owner_type, :string
    field :processor, :string
    field :processor_id, :string
    field :processor_plan, :string
    field :quantity, :integer
    field :status, :string
    field :trial_ends_at, :naive_datetime
    field :update_url, :string

    # timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:owner_type, :owner_id, :name, :processor, :processor_id, :processor_plan, :quantity, :trial_ends_at, :ends_at, :status, :update_url, :cancel_url])
    |> validate_required([:owner_type, :owner_id, :name, :processor, :processor_id, :processor_plan, :quantity, :ends_at, :status, :update_url, :cancel_url])
  end
end
