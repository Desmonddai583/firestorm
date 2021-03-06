defmodule FirestormWeb.CategoryController do
  use FirestormWeb, :controller

  alias Firestorm.Forums
  alias FirestormWeb.Plugs.RequireUser
  alias Firestorm.Forums.Category

  plug RequireUser when action in [:new, :create]

  def index(conn, _params) do
    categories =
      Forums.list_categories()

    render(conn, "index.html", categories: categories)
  end

  def new(conn, _params) do
    changeset = Forums.change_category(%Category{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"category" => category_params}) do
    case Forums.create_category(category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: category_path(conn, :show, category))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    category =
      id
      |> Forums.get_category!

    threads =
      category
      |> Forums.recent_threads(current_user(conn))

    render(conn, "show.html", category: category, threads: threads)
  end

  def edit(conn, %{"id" => id}) do
    category = Forums.get_category!(id)
    changeset = Forums.change_category(category)
    render(conn, "edit.html", category: category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Forums.get_category!(id)

    case Forums.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: category_path(conn, :show, category))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Forums.get_category!(id)
    {:ok, _category} = Forums.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: category_path(conn, :index))
  end
end
