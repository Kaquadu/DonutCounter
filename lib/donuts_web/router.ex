defmodule DonutsWeb.Router do
  use DonutsWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", DonutsWeb do
    # Use the default browser stack
    pipe_through(:browser)
    get("/", PageController, :index)
    get("/sign-in", SessionController, :sign_in)
    get("/auth", SessionController, :auth)
    get("/loggedin", PageController, :logged_in)
    post("/add-donut", PageController, :add_donut)
  end

  scope "/events", DonutsWeb do
    post("/event-occured", PageController, :event_handler)
  end

  # Other scopes may use custom stacks.
  # scope "/api", DonutsWeb do
  #   pipe_through :api
  # end
end
