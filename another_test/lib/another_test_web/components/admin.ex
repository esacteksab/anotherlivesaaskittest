defmodule AnotherTestWeb.Components.Admin do
  @moduledoc """
  Admin components
  """
  use Phoenix.Component

  import AnotherTestWeb.CoreComponents, only: [icon: 1]
  alias Phoenix.LiveView.JS

  def show_admin_sidebar(js \\ %JS{}) do
    js
    |> JS.remove_class("hidden", to: "#sidebar")
    |> JS.remove_class("hidden", to: "#toggleSidebarMobileClose")
    |> JS.add_class("hidden", to: "#toggleSidebarMobileHamburger")
    |> JS.show(
      to: "#sidebarBackdrop",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
  end

  def hide_admin_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#sidebarBackdrop",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> JS.add_class("hidden", to: "#toggleSidebarMobileClose")
    |> JS.remove_class("hidden", to: "#toggleSidebarMobileHamburger")
    |> JS.add_class("hidden", to: "#sidebar")
  end

  def toggle_dropdown(id, js \\ %JS{}) do
    js
    |> JS.toggle(
      to: id,
      in:
        {"transition ease-out duration-150", "opacity-0 translate-y-1",
         "opacity-100 translate-y-0"},
      out:
        {"transition ease-in duration-100", "opacity-100 translate-y-0",
         "opacity-0 translate-y-1"}
    )
  end

  def close_dropdown(id, js \\ %JS{}) do
    js
    |> JS.hide(
      to: id,
      transition:
        {"transition ease-in duration-100", "opacity-100 translate-y-0",
         "opacity-0 translate-y-1"}
    )
  end

  attr :title, :string, required: true
  slot :inner_block
  slot :link

  def admin_page_heading(assigns) do
    ~H"""
    <div class="mb-4">
      <nav class="flex mb-5" aria-label="Breadcrumb">
        <ol class="inline-flex items-center space-x-1 text-sm font-medium md:space-x-2">
          <li :for={{link, idx} <- Enum.with_index(@link)}>
            <div class="flex items-center">
              <.icon :if={idx == 0} name="hero-home" class="w-5 h-5 mr-2.5" />
              <svg
                :if={idx > 0}
                class="w-6 h-6 text-gray-400"
                fill="currentColor"
                viewBox="0 0 20 20"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  fill-rule="evenodd"
                  d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                  clip-rule="evenodd"
                >
                </path>
              </svg>
              <%= render_slot(link) %>
            </div>
          </li>
        </ol>
      </nav>
      <div class="flex items-center justify-between">
        <h1 class="text-xl font-semibold text-gray-900 sm:text-2xl dark:text-white">
          <%= @title %>
        </h1>
        <div class="flex space-x-2">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end
end
