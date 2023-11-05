defmodule Notion.User.Creation do
  defstruct(
    username: "",
    email: "",
    password: ""
  )

  @type t :: %Notion.User.Creation{
          username: String.t(),
          email: String.t(),
          password: String.t()
        }

  @spec registered_users :: [t()]
  def registered_users do
    [
      %Notion.User.Creation{username: "a.landi", email: "a.landi@gmail.com", password: "1234"},
      %Notion.User.Creation{username: "f.molla", email: "f.molla@gmail.com", password: "3304"},
      %Notion.User.Creation{
        username: "m.slepowron",
        email: "m.slepowron@gmail.com",
        password: "1655"
      }
    ]
  end

  @spec add_user(t) :: [t()]
  # pattern match to assure that user is of type %user before appending.
  def add_user(%Notion.User.Creation{} = user) do
    # appends
    [user | registered_users()]
  end

  def update_password(username, password) do
    # 1. filter out the user that we want to update
    # 2. Create a new user with the new password: ALL DATA TYPES ARE INMUTABLE
    # 3. add the user to our registered users and take out the old entry

    # 1
    [old_user] =
      Enum.filter(registered_users(), fn %{username: registered_username} ->
        registered_username == username
      end)

    # 2
    new_user = %{old_user | password: password}

    # 3
    [new_user | registered_users() |> List.delete(old_user)]
    # Pipe operates from right to left: 1rt it removes the item then it appends the new one
  end

  # podria ser una funcion privada del modulo. Chequea que un usuario que se quiere loggear ya este registrdado
  def authenticate(username) when is_binary(username) do # se fija que se reciba una cadena de caracteres
    case Enum.find(registered_users(), fn %{username: registered_username} -> registered_username == username end) do
      %Notion.User.Creation{} -> {:ok, "authorized"}
      nil -> {:error, "user is not registered"}
    end
  end


  def verify_password(user, password) when is_binary(user) and is_binary(password) do
    with {:ok, _msg} <- authenticate(user) docl
      case Enum.find(registered_users(), fn %{password: registered_password} -> registered_password == password end) do
        %Notion.User.Creation{} -> {:ok, "password verified"}
        nil -> {:error, "wrong password"}
      end
    end
  end

  def login(user, password) do
    with {:ok, _msg} <- authenticate(user), #el _ es que lo que me llega aca no me importa
         {:ok, _msg} <- verify_password(user, password) do
      {:ok, "#{user} logged in successfully"}
    else
      {:error, msg} -> {:error, msg}
      _ -> :unauthorized
    end
  end

end
