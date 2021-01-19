defmodule TrackearAuthWeb.SubscriptionControllerTest do
  use TrackearAuthWeb.ConnCase

  alias TrackearAuth.Billings

  @create_attrs %{cancel_url: "some cancel_url", ends_at: ~N[2010-04-17 14:00:00], name: "some name", owner_id: 42, owner_type: "some owner_type", processor: "some processor", processor_id: "some processor_id", processor_plan: "some processor_plan", quantity: 42, status: "some status", traisl_ends_at: ~N[2010-04-17 14:00:00], update_url: "some update_url"}
  @update_attrs %{cancel_url: "some updated cancel_url", ends_at: ~N[2011-05-18 15:01:01], name: "some updated name", owner_id: 43, owner_type: "some updated owner_type", processor: "some updated processor", processor_id: "some updated processor_id", processor_plan: "some updated processor_plan", quantity: 43, status: "some updated status", traisl_ends_at: ~N[2011-05-18 15:01:01], update_url: "some updated update_url"}
  @invalid_attrs %{cancel_url: nil, ends_at: nil, name: nil, owner_id: nil, owner_type: nil, processor: nil, processor_id: nil, processor_plan: nil, quantity: nil, status: nil, traisl_ends_at: nil, update_url: nil}

  def fixture(:subscription) do
    {:ok, subscription} = Billings.create_subscription(@create_attrs)
    subscription
  end

  describe "index" do
    test "lists all pay_subscriptions", %{conn: conn} do
      conn = get(conn, Routes.subscription_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Pay subscriptions"
    end
  end

  describe "new subscription" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.subscription_path(conn, :new))
      assert html_response(conn, 200) =~ "New Subscription"
    end
  end

  describe "create subscription" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.subscription_path(conn, :create), subscription: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.subscription_path(conn, :show, id)

      conn = get(conn, Routes.subscription_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Subscription"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.subscription_path(conn, :create), subscription: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Subscription"
    end
  end

  describe "edit subscription" do
    setup [:create_subscription]

    test "renders form for editing chosen subscription", %{conn: conn, subscription: subscription} do
      conn = get(conn, Routes.subscription_path(conn, :edit, subscription))
      assert html_response(conn, 200) =~ "Edit Subscription"
    end
  end

  describe "update subscription" do
    setup [:create_subscription]

    test "redirects when data is valid", %{conn: conn, subscription: subscription} do
      conn = put(conn, Routes.subscription_path(conn, :update, subscription), subscription: @update_attrs)
      assert redirected_to(conn) == Routes.subscription_path(conn, :show, subscription)

      conn = get(conn, Routes.subscription_path(conn, :show, subscription))
      assert html_response(conn, 200) =~ "some updated cancel_url"
    end

    test "renders errors when data is invalid", %{conn: conn, subscription: subscription} do
      conn = put(conn, Routes.subscription_path(conn, :update, subscription), subscription: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Subscription"
    end
  end

  describe "delete subscription" do
    setup [:create_subscription]

    test "deletes chosen subscription", %{conn: conn, subscription: subscription} do
      conn = delete(conn, Routes.subscription_path(conn, :delete, subscription))
      assert redirected_to(conn) == Routes.subscription_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.subscription_path(conn, :show, subscription))
      end
    end
  end

  defp create_subscription(_) do
    subscription = fixture(:subscription)
    %{subscription: subscription}
  end
end
