# SchwiftyApp

A SwiftUI iOS app for browsing characters and episodes from the [Rick and Morty API](https://rickandmortyapi.com).

## What it does

- **Character list** — paginated, infinite-scrolling list of all characters in the show, with pull-to-refresh.
- **Character details** — shows a data sheet for each character (status, species, gender, origin, location) along with the list of episodes they appear in.
- **Episode details** — shows episode info (name, code, air date) and the cast of characters featured in that episode.
- **Cross-navigation** — jump from a character into any of their episodes, then into other characters in that episode, and so on.
- **Favorites** — star characters to pin them to a "Favorites" section at the top of the character list; swipe to unfavorite.

## Built with

- SwiftUI
- [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture)
- [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) for the API client
- Swift Testing framework for unit tests
