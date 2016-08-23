defmodule Runnel.Router do
  use Runnel.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth_browser do
    plug Runnel.RedirectOrSigninCookie
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Runnel do
    pipe_through :browser
    pipe_through :auth_browser

    get "/", PageController, :index
  end

  scope "/auth", Runnel do
    pipe_through :browser

    get "/", AuthController, :index
    post "/create_session", AuthController, :create_session
  end
end
