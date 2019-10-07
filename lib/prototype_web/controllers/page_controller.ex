defmodule PrototypeWeb.PageController do
  use PrototypeWeb, :controller

  def index(conn, _params) do
    code = Earmark.as_html!(markdown, code_class_prefix: "language-")

    render(conn, "index.html", code: code)
  end

  def markdown do
    """
    # Welcome to the Prototype

    This is a paragraph before the markdown code comes. I don't 'need' to drink. I can quit anytime I want! And remember, don't do anything that affects anything, unless it turns out you were supposed to, in which case, for the love of God, don't not do it!

    ``` elixir
    # Elixir
      defmodule Testing do
         def say(something) do
           IO.inspect(something, label: "You said")
         end
      end
    ```

    ``` sql
    # SQL
    SELECT * FROM my_table WHERE id in ['1', '2', '3'];
    ```

    """
  end
end
