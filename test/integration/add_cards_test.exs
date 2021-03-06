defmodule PhoenixTrello.AddCardsTest do
  use PhoenixTrello.IntegrationCase

  alias PhoenixTrello.{User, Board}

  setup do
    user = build(:user)
    |> User.changeset(%{password: "12345678"})
    |> Repo.insert!

    board = user
    |> build_assoc(:owned_boards)
    |> Board.changeset(%{name: "My new board"})
    |> Repo.insert!
    |> Repo.preload([:user, :invited_users, lists: :cards])

    list = board
      |> build_assoc(:lists)
      |> PhoenixTrello.List.changeset(%{name: "First list"})
      |> Repo.insert!


    {:ok, %{user: user, board: board, list: list}}
  end

  @tag :integration
  test "Clicking on a previously created list", %{user: user, board: board, list: list} do
    user_sign_in(%{user: user, board: board})

    navigate_to "/boards/#{Board.slug_id(board)}"

    assert element_visible?({:css, ".view-container.boards.show"})

    assert element_visible?({:id, "list_#{list.id}"})

    find_element(:id, "list_#{list.id}")
    |> find_within_element(:css, ".add-new")
    |> click

    assert element_visible?({:id, "new_card_form"})

    new_card_form = find_element(:id, "new_card_form")

    new_card_form
    |> find_within_element(:id, "card_name")
    |> fill_field("New card")

    new_card_form
    |> find_within_element(:css, "button")
    |> click

    card = board
      |> last_card

    assert element_visible?({:id, "card_#{card.id}"})
    assert page_source =~ card.name
  end

  defp last_card(board) do
    Board
    |> Repo.get!(board.id)
    |> Repo.preload([:cards])
    |> Map.get(:cards)
    |> List.last
  end
end
