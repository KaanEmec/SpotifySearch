# SpotifySearch
A Swift class for making a song or artist search using Spotify API and another class for storing search results.

USAGE:
Add the spotifySearch.swift file into your project.
Create an instance of spotifySearch Class and use following functions to do and handle song or artist search:

- spotifySearch.searchSpotifyFor (searchTerm, searchType, designatedArtist, handler)
 
- spotifySearch.stopSearching()

- spotifySearch.spotifySearchResultsToStringArray(results) -> [String]

Search results will be returned to the handler you specified in the function "searchSpotifyFor" with an array of spotifySearchResult class.
