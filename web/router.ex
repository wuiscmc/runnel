defmodule Runnel.Router do
  use Runnel.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Runnel do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/main", PageController, :main
    post "/create_session", PageController, :create_session
    get "/see_stuff", PageController, :see_stuff
  end

  # Other scopes may use custom stacks.
  # scope "/api", Runnel do
  #   pipe_through :api
  # end
end
