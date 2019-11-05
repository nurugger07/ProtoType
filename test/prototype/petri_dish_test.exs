defmodule Prototype.PetriDishTest do
  use ExUnit.Case

  alias Prototype.PetriDish

  @objects [
    %{id: "A", x: 1, y: 1},
    %{id: "B", x: 4, y: 2},
    %{id: "C", x: 4, y: 4}
  ]

  setup do
    PetriDish.clear()
    :ok
  end

  describe "create/1" do
    test "create new object in the dish" do
      assert :ok = PetriDish.create(%{id: "Z", x: 50, y: 51})
      assert [
        %{id: "Z", x: 50, y: 51},
      ] = PetriDish.all()
    end

    test "return error with missing fields" do
      assert {:error, :invalid_object} = PetriDish.create(%{})
    end
  end

  describe "update/1" do
    test "update an object in the dish" do
      seed_objects()
      assert :ok = PetriDish.update(%{id: "B", x: 50, y: 51})
      assert [
        %{id: "A", x: 1, y: 1},
        %{id: "B", x: 50, y: 51},
        %{id: "C", x: 4, y: 4}
      ] = PetriDish.all()
    end

    test "return error with missing fields" do
      assert {:error, :invalid_object} = PetriDish.update(%{})
    end
  end

  describe "remove/1" do
    test "remove an object from the dish" do
      seed_objects()
      assert :ok = PetriDish.remove(%{id: "B"})
      assert [
        %{id: "A", x: 1, y: 1},
        %{id: "C", x: 4, y: 4}
      ] = PetriDish.all()
    end

    test "return error with missing id" do
      assert {:error, :missing_id} = PetriDish.remove(%{})
    end
  end

  describe "get/1" do
    test "get an object from the dish" do
      seed_objects()
      assert %{id: "C", x: 4, y: 4} = PetriDish.get(%{id: "C"})
    end

    test "return error with missing id" do
      assert {:error, :missing_id} = PetriDish.get(%{})
    end
  end

  describe "all/0" do
    test "return all objects in the dish" do
      assert [] = PetriDish.all()
      seed_objects()
      assert @objects = PetriDish.all()
    end
  end

  describe "clear/0" do
    test "clear objects from the dish" do
      seed_objects()
      assert @objects = PetriDish.all()
      assert :ok = PetriDish.clear()
      assert [] = PetriDish.all()
    end
  end

  def seed_objects do
    Enum.each(@objects, &PetriDish.create/1)
  end

end
