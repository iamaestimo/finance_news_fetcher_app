defmodule FinanceNewsWeb.TopicLive do
  use FinanceNewsWeb, :live_view
  alias FinanceNews.Topics
  alias FinanceNews.Topics.AvailableTopics

  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      user_topics = Topics.list_user_topics(socket.assigns.current_user)

      socket = assign(socket,
        available_topics: AvailableTopics.all(),
        selected_topics: MapSet.new(Enum.map(user_topics, & &1.topic)),
        error_message: nil
      )

      {:ok, socket}
    else
      {:ok, push_navigate(socket, to: ~p"/users/log_in")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Select Your Topics</h1>

      <p class="mb-4 text-gray-600">
        Choose up to 3 topics that interest you. We'll customize your news feed based on your selection.
      </p>

      <%= if @error_message do %>
        <div class="mb-4 p-4 bg-red-100 text-red-700 rounded-md">
          <%= @error_message %>
        </div>
      <% end %>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for {topic_id, label} <- @available_topics do %>
          <div class="relative">
            <div class={"p-4 rounded-lg border-2 cursor-pointer #{if MapSet.member?(@selected_topics, topic_id), do: "border-blue-500 bg-blue-50", else: "border-gray-200 hover:border-blue-300"}"}>
              <label class="flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  value={topic_id}
                  checked={MapSet.member?(@selected_topics, topic_id)}
                  phx-click="toggle_topic"
                  phx-value-topic={topic_id}
                  class="hidden"
                />
                <div class="text-lg font-medium"><%= label %></div>
              </label>
            </div>
          </div>
        <% end %>
      </div>

      <div class="mt-8 flex justify-end">
        <button
          phx-click="save_topics"
          class="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
          disabled={MapSet.size(@selected_topics) == 0}
        >
          Continue to News Feed
        </button>
      </div>
    </div>
    """
  end

  def handle_event("toggle_topic", %{"topic" => topic}, socket) do
    current_topics = socket.assigns.selected_topics
    is_selected = MapSet.member?(current_topics, topic)
    action = if is_selected, do: "deselect", else: "select"

    span = Appsignal.Tracer.create_span("toggle_topic")
    Appsignal.Span.set_attribute(span, "topic_action", action)
    Appsignal.Span.set_attribute(span, "topic", topic)
    Appsignal.Span.set_attribute(span, "total_topics", MapSet.size(current_topics))
    Appsignal.Span.close(span)

    new_topics = if is_selected do
      MapSet.delete(current_topics, topic)
    else
      if MapSet.size(current_topics) >= 3 do
        socket = assign(socket, error_message: "You can select up to 3 topics")
        {:noreply, socket}
      else
        MapSet.put(current_topics, topic)
      end
    end

    {:noreply, assign(socket, selected_topics: new_topics, error_message: nil)}
  end

  def handle_event("save_topics", _, socket) do
    Appsignal.instrument("Topics.save_topics", fn ->
      user = socket.assigns.current_user
      topics = MapSet.to_list(socket.assigns.selected_topics)

      case Topics.update_user_topics(user, topics) do
        {:ok, _} ->
          {:noreply, push_navigate(socket, to: ~p"/feed")}

        {:error, _} ->
          {:noreply, assign(socket, error_message: "Failed to save topics. Please try again.")}
      end
    end)
  end
end
