defmodule TrackearAuth.BillingsTest do
  use TrackearAuth.DataCase

  alias TrackearAuth.Billings

  describe "pay_subscriptions" do
    alias TrackearAuth.Billings.Subscription

    @valid_attrs %{cancel_url: "some cancel_url", ends_at: ~N[2010-04-17 14:00:00], name: "some name", owner_id: 42, owner_type: "some owner_type", processor: "some processor", processor_id: "some processor_id", processor_plan: "some processor_plan", quantity: 42, status: "some status", traisl_ends_at: ~N[2010-04-17 14:00:00], update_url: "some update_url"}
    @update_attrs %{cancel_url: "some updated cancel_url", ends_at: ~N[2011-05-18 15:01:01], name: "some updated name", owner_id: 43, owner_type: "some updated owner_type", processor: "some updated processor", processor_id: "some updated processor_id", processor_plan: "some updated processor_plan", quantity: 43, status: "some updated status", traisl_ends_at: ~N[2011-05-18 15:01:01], update_url: "some updated update_url"}
    @invalid_attrs %{cancel_url: nil, ends_at: nil, name: nil, owner_id: nil, owner_type: nil, processor: nil, processor_id: nil, processor_plan: nil, quantity: nil, status: nil, traisl_ends_at: nil, update_url: nil}

    def subscription_fixture(attrs \\ %{}) do
      {:ok, subscription} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Billings.create_subscription()

      subscription
    end

    test "list_pay_subscriptions/0 returns all pay_subscriptions" do
      subscription = subscription_fixture()
      assert Billings.list_pay_subscriptions() == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()
      assert Billings.get_subscription!(subscription.id) == subscription
    end

    test "create_subscription/1 with valid data creates a subscription" do
      assert {:ok, %Subscription{} = subscription} = Billings.create_subscription(@valid_attrs)
      assert subscription.cancel_url == "some cancel_url"
      assert subscription.ends_at == ~N[2010-04-17 14:00:00]
      assert subscription.name == "some name"
      assert subscription.owner_id == 42
      assert subscription.owner_type == "some owner_type"
      assert subscription.processor == "some processor"
      assert subscription.processor_id == "some processor_id"
      assert subscription.processor_plan == "some processor_plan"
      assert subscription.quantity == 42
      assert subscription.status == "some status"
      assert subscription.traisl_ends_at == ~N[2010-04-17 14:00:00]
      assert subscription.update_url == "some update_url"
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billings.create_subscription(@invalid_attrs)
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{} = subscription} = Billings.update_subscription(subscription, @update_attrs)
      assert subscription.cancel_url == "some updated cancel_url"
      assert subscription.ends_at == ~N[2011-05-18 15:01:01]
      assert subscription.name == "some updated name"
      assert subscription.owner_id == 43
      assert subscription.owner_type == "some updated owner_type"
      assert subscription.processor == "some updated processor"
      assert subscription.processor_id == "some updated processor_id"
      assert subscription.processor_plan == "some updated processor_plan"
      assert subscription.quantity == 43
      assert subscription.status == "some updated status"
      assert subscription.traisl_ends_at == ~N[2011-05-18 15:01:01]
      assert subscription.update_url == "some updated update_url"
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()
      assert {:error, %Ecto.Changeset{}} = Billings.update_subscription(subscription, @invalid_attrs)
      assert subscription == Billings.get_subscription!(subscription.id)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = Billings.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Billings.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = Billings.change_subscription(subscription)
    end
  end

  describe "pay_charges" do
    alias TrackearAuth.Billings.Charge

    @valid_attrs %{amount: 42, created_at: ~N[2010-04-17 14:00:00], owner_id: 42, owner_type: "some owner_type", processor: "some processor", processor_id: "some processor_id", receipt_url: "some receipt_url", updated_at: ~N[2010-04-17 14:00:00]}
    @update_attrs %{amount: 43, created_at: ~N[2011-05-18 15:01:01], owner_id: 43, owner_type: "some updated owner_type", processor: "some updated processor", processor_id: "some updated processor_id", receipt_url: "some updated receipt_url", updated_at: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{amount: nil, created_at: nil, owner_id: nil, owner_type: nil, processor: nil, processor_id: nil, receipt_url: nil, updated_at: nil}

    def charge_fixture(attrs \\ %{}) do
      {:ok, charge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Billings.create_charge()

      charge
    end

    test "list_pay_charges/0 returns all pay_charges" do
      charge = charge_fixture()
      assert Billings.list_pay_charges() == [charge]
    end

    test "get_charge!/1 returns the charge with given id" do
      charge = charge_fixture()
      assert Billings.get_charge!(charge.id) == charge
    end

    test "create_charge/1 with valid data creates a charge" do
      assert {:ok, %Charge{} = charge} = Billings.create_charge(@valid_attrs)
      assert charge.amount == 42
      assert charge.created_at == ~N[2010-04-17 14:00:00]
      assert charge.owner_id == 42
      assert charge.owner_type == "some owner_type"
      assert charge.processor == "some processor"
      assert charge.processor_id == "some processor_id"
      assert charge.receipt_url == "some receipt_url"
      assert charge.updated_at == ~N[2010-04-17 14:00:00]
    end

    test "create_charge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billings.create_charge(@invalid_attrs)
    end

    test "update_charge/2 with valid data updates the charge" do
      charge = charge_fixture()
      assert {:ok, %Charge{} = charge} = Billings.update_charge(charge, @update_attrs)
      assert charge.amount == 43
      assert charge.created_at == ~N[2011-05-18 15:01:01]
      assert charge.owner_id == 43
      assert charge.owner_type == "some updated owner_type"
      assert charge.processor == "some updated processor"
      assert charge.processor_id == "some updated processor_id"
      assert charge.receipt_url == "some updated receipt_url"
      assert charge.updated_at == ~N[2011-05-18 15:01:01]
    end

    test "update_charge/2 with invalid data returns error changeset" do
      charge = charge_fixture()
      assert {:error, %Ecto.Changeset{}} = Billings.update_charge(charge, @invalid_attrs)
      assert charge == Billings.get_charge!(charge.id)
    end

    test "delete_charge/1 deletes the charge" do
      charge = charge_fixture()
      assert {:ok, %Charge{}} = Billings.delete_charge(charge)
      assert_raise Ecto.NoResultsError, fn -> Billings.get_charge!(charge.id) end
    end

    test "change_charge/1 returns a charge changeset" do
      charge = charge_fixture()
      assert %Ecto.Changeset{} = Billings.change_charge(charge)
    end
  end
end
