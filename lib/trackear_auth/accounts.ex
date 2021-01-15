defmodule TrackearAuth.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias TrackearAuth.Repo
  alias TrackearAuth.Accounts.User
  alias TrackearAuth.Accounts.Session

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user from the email and password.

  ## Examples

      iex> get_user_from_credentials("foo@bar.com", "baz")
      {:ok, %User{}}

      iex> create_user("foo@bar.com", "incorrect-password")
      {:error, :invalid_credentials}

  """
  def get_user_from_credentials(email, password) do
    case Repo.get_by(User, email: email) do
      %User{} = user ->
        matches = Bcrypt.verify_pass(password, user.encrypted_password)
        if matches, do: {:ok, user}, else: {:error, :invalid_credentials}
      nil ->
        {:error, :invalid_credentials}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns the list of session.

  ## Examples

      iex> list_session()
      [%Session{}, ...]

  """
  def list_session do
    Repo.all(Session)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id)

  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a user and from it, create a session.

  ## Examples

      iex> create_user_and_return_session(%{field: value})
      {:ok, %Session{}}

      iex> create_user_and_return_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_and_return_session(attrs \\ %{}) do
    case create_user(attrs) do
      {:ok, user} ->
        create_session(%{ user_id: user.id })
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Get a user from email. If found, a session will be created
  for the user. If no user is found, a new one will be created
  and then, a session for it will be returned.

  ## Examples

      iex> get_or_create_user_and_return_session(%{email: "foo@email.com"})
      {:ok, %Session{}}

      iex> get_or_create_user_and_return_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def get_or_create_user_and_return_session(attrs \\ %{}) do
    case Repo.get_by(User, email: attrs.email) do
      %User{} = user ->
        create_session(%{ user_id: user.id })
      nil ->
        create_user_and_return_session(attrs)
    end
  end

  @doc """
  Creates a new session from credentials (email and password).

  ## Examples

      iex> create_session_from_credentials("foo@email.com", "bar")
      {:ok, %Session{}}

      iex> create_session_from_credentials("foo@email.com", "incorrect-pass")
      {:error, %Changeset{}}

  """
  def create_session_from_credentials(email, password) do
    case get_user_from_credentials(email, password) do
      {:ok, %User{} = user} ->
        create_session(%{ user_id: user.id })
      {:error, _} ->
        change_user(%User{}, %{email: email, password: password})
        |> Ecto.Changeset.add_error(:base, "Invalid credentials")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  @doc """
  Updates a session.

  ## Examples

      iex> update_session(session, %{field: new_value})
      {:ok, %Session{}}

      iex> update_session(session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.

  ## Examples

      iex> change_session(session)
      %Ecto.Changeset{data: %Session{}}

  """
  def change_session(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end
end
