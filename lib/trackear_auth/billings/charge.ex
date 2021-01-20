defmodule TrackearAuth.Billings.Charge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pay_charges" do
    field :amount, :integer
    field :owner_id, :integer
    field :owner_type, :string
    field :processor, :string
    field :processor_id, :string
    field :receipt_url, :string
    field :created_at, :naive_datetime
    field :updated_at, :naive_datetime

    # timestamps()
  end

  @doc false
  def changeset(charge, attrs) do
    charge
    |> cast(attrs, [:owner_type, :owner_id, :processor, :processor_id, :amount, :created_at, :updated_at, :receipt_url])
    |> validate_required([:owner_type, :owner_id, :processor, :processor_id, :amount, :receipt_url])
    |> set_ruby_timestamp()
  end

  defp set_ruby_timestamp(changeset) do
    today = NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)

    changeset
    |> put_change(:created_at, today)
    |> put_change(:updated_at, today)
  end
end
