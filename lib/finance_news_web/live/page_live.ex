defmodule FinanceNewsWeb.PageLive do
  use FinanceNewsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-12">
      <div class="text-center">
        <h1 class="text-4xl font-bold mb-4">Financial News Tracker</h1>
        <p class="text-xl text-gray-600 mb-8">
          Stay updated with the latest financial news just made for you.
        </p>

        <div class="space-x-4">
          <%= if @current_user do %>
            <.link
              navigate={~p"/feed"}
              class="inline-block bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700"
            >
              Go to Feed
            </.link>
          <% else %>
            <.link
              navigate={~p"/users/register"}
              class="inline-block bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700"
            >
              Sign Up
            </.link>
            <.link
              navigate={~p"/users/log_in"}
              class="inline-block bg-gray-200 text-gray-800 px-6 py-2 rounded-md hover:bg-gray-300"
            >
              Log In
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
