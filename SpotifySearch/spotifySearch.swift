//
//  spotifySearch.swift
//  itunesSearchSuggestion
//
//  Created by Kaan Emeç on 22.04.2015.
//  Copyright (c) 2015 kaanemec. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

enum spotifySearchType {
    case Artist
    case Song
}



class spotifySearchResult : NSObject {
    var artist=""
    var track=""
    var duration=0
    var spotifyURL = NSURL()
    var spotifyURI = NSURL()
    
    override func isEqual(theObject: AnyObject?) -> Bool {
        if let myObject = theObject as? spotifySearchResult {
            return (myObject.artist.uppercaseString == self.artist.uppercaseString && myObject.track.uppercaseString == self.track.uppercaseString)
        }
        return false
    }
}



class spotifySearch: NSObject {

    var searching: Bool = false
    var searchRequest: Alamofire.Request?
    
    func escapedSearchTerm(string: String) -> String {
        return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? ""
    }
    
    func generateSpotifySongSearchURL(query: String, designatedArtist: String = "") -> String {
        var finalQuery:String = query
        if designatedArtist.characters.count>0 { finalQuery = "artist:\(designatedArtist) track:\(query)" } else { finalQuery = query }
        return "https://api.spotify.com/v1/search?q=\(escapedSearchTerm(finalQuery))*&type=track&limit=10"
    }
    
    
    func generateSpotifyArtistSearchURL(query: String) -> String {
        return "https://api.spotify.com/v1/search?q=\(escapedSearchTerm(query))*&type=artist&limit=10"
    }
    
    
    func searchSpotifyFor(searchTerm: String, searchType: spotifySearchType, designatedArtist: String = "", handler: ([spotifySearchResult]) -> Void) {
            
            self.searching = true
            
            if searchType == spotifySearchType.Artist {
                searchRequest = Alamofire.request(.GET, generateSpotifyArtistSearchURL(searchTerm)).responseJSON { (responseData) -> Void in
                    if((responseData.result.value) != nil) {
                        self.searching = false
                        let jsonResult = JSON(responseData.result.value!)
                        if let jsonArtists: Array<JSON> = jsonResult["artists"]["items"].arrayValue {
                            var suggestionResults: [spotifySearchResult] = []
                            for artist in jsonArtists {
                                if let artist:String = artist["name"].stringValue {
                                    let sugresult = spotifySearchResult()
                                    sugresult.artist = artist
                                    if !suggestionResults.contains(sugresult) {
                                        suggestionResults.append(sugresult)
                                    }
                                }
                            }
                            handler(suggestionResults)
                        }
                    }
                }
            } else if searchType == spotifySearchType.Song {
                searchRequest = Alamofire.request(.GET, generateSpotifySongSearchURL(searchTerm)).responseJSON { (responseData) -> Void in
                    if((responseData.result.value) != nil) {
                        self.searching = false
                        let jsonResult = JSON(responseData.result.value!)
                        if let jsonTracks: Array<JSON> = jsonResult["tracks"]["items"].arrayValue {
                            var suggestionResults: [spotifySearchResult] = []
                            for track in jsonTracks {
                                if let title:String = track["name"].stringValue {
                                    let sugresult = spotifySearchResult()
                                    sugresult.track = title
                                    sugresult.artist = track["artists"][0]["name"].stringValue ?? ""
                                    sugresult.spotifyURL = NSURL(string: track["externalUrls"]["spotify"].stringValue ?? "")!
                                    sugresult.spotifyURI = NSURL(string: track["uri"].stringValue ?? "")!
                                    sugresult.duration = (track["duration_ms"].intValue ?? 0) / 1000
                                    if !suggestionResults.contains(sugresult) {
                                        suggestionResults.append(sugresult)
                                    }
                                }
                            }
                            handler(suggestionResults)
                        }
                    }
                }
            }
        
    }
    
    
    func stopSearching() {
        self.searchRequest?.cancel()
        self.searching = false
    }
    
    
    func spotifySearchResultsToStringArray(results: [spotifySearchResult]) -> [String] {
        var stringResutls: [String] = []
        for result in results {
            if result.track.characters.count>1 {
                stringResutls.append(result.track + " (" + result.artist + ")")
            } else {
                stringResutls.append(result.artist)
            }
        }
        return stringResutls
    }
    
    

}
