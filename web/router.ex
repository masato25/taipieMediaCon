defmodule TaipieMediaCon.Router do
  use TaipieMediaCon.Web, :router

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

  scope "/", TaipieMediaCon do
    pipe_through :browser # Use the default browser stack

    resources "/time_jobs", TimeJobController
    # get "/", PageController, :index
    #get "/", JobCalendarController , :index
    get "/", JobTemplateController, :indexhtml
    get "/program", ProgramController, :indexhtml
    get "/login", PageController, :login
    get "/logout", PageController, :logout

    get "/template", JobTemplateController, :indexhtml
    get "/template/:id", JobCalendarController , :indexv2
    get "/avatar", AvatarController, :indexhtml
  end

  # Other scopes may use custom stacks.
  scope "/api", TaipieMediaCon do
    pipe_through :api
    # get "/time_jobs_list", TimeJobController, :list
    get "/time_jobs_list/:template_id", TimeJobController, :list

    get "/time_jobs_list_help", TimeJobController, :listp
    post "/time_jobs_create", TimeJobController, :jcreate
    delete "/time_jobs/:id", TimeJobController, :jdelete
    post "/time_jobs_copy_hour", TimeJobController, :copyHoursData
    post "/time_jobs_copy_day", TimeJobController, :copyDayData
    delete "/time_jobs_delete_date",  TimeJobController, :jdelete_d_date
    resources "/program", ProgramController, except: [:new, :edit]
    post "/login", PageController, :login_api
    get "/agents", ProgramController, :agents

    #new feature
    resources "/job_template", JobTemplateController, except: [:new, :edit]
    resources "/avatar", AvatarController, except: [:new, :edit]
  end

end
