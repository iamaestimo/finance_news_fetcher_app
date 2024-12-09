# Finance News Fetcher App

Phoenix LiveView app to fetch the latest finance news according to a user's topic preferences e.g. "Crypto", "Property", "Financials" news topics.

## How it works

- User creates an account
- User is redirected to page to select (financial news) topics of interest
- User gets toa "feed" page with all the latest news.

## Stack

This app is built with:

- Phoenix LiveView
- Postgresql
- Alphavantage API (get your key from their website)

## How to setup

- Fork/clone the repo
- Create a `dev.secret.exs` file and insert your Alphavantage API key in there.
- Create your database and update `dev.exs` accordingly.
- Run the server with `mix phx.server`
