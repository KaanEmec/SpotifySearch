//
//  SpotifySearch.swift
//
//  Created by Kaan Emeç on 22.04.2015.
//  Copyright (c) 2015 kaanemec. All rights reserved.
//
//  Create an instance of spotifySearch Class and use following functions to do and handle song or artist search:
//      - spotifySearch.searchSpotifyFor
//      - spotifySearch.stopSearching
//      - spotifySearch.spotifySearchResultsToStringArray
//
//  Search results will be returned to the handler you specified in the function "searchSpotifyFor" with an array of spotifySearchResult class.



import UIKit

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
    var searchTask: NSURLSessionDataTask!
    
    func searchSpotifyFor(searchTerm: String, searchType: spotifySearchType, designatedArtist: String = "", handler: ([spotifySearchResult]) -> Void) {
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let theSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = theSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            var urlPath = ""
            if searchType == spotifySearchType.Artist {
                urlPath = "https://api.spotify.com/v1/search?q=artist:\(escapedSearchTerm)*&type=artist&limit=10"
            } else {
                if count(designatedArtist)>0 {
                    let escapedArtist = designatedArtist.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                    urlPath = "https://api.spotify.com/v1/search?q=artist:\(escapedArtist!)%20track:\(escapedSearchTerm)*&type=track&limit=10"
                } else {
                    urlPath = "https://api.spotify.com/v1/search?q=track:\(escapedSearchTerm)*&type=track&limit=10"
                }
            }
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            self.searching = true
            self.searchTask = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                var err: NSError?
                
                if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                    
                    if let jsonTracks = jsonResult["tracks"] as? NSDictionary {
                        if let results:NSArray = jsonTracks["items"] as? NSArray {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.searching = false
                                var suggestionResults: [spotifySearchResult] = []
                                for result in results {
                                    if let resultData: NSDictionary = result as? NSDictionary {
                                        var sURL = ""
                                        if let externalUrls = resultData["external_urls"] as? NSDictionary {
                                            if let spotifyURL = externalUrls ["spotify"] as? String {
                                                sURL = spotifyURL
                                            }
                                        }
                                        if let artistArray = resultData["artists"] as? NSArray {
                                            if let firstArtist: NSDictionary = artistArray[0] as? NSDictionary{
                                                let artist = firstArtist["name"] as! String
                                                let titleData = resultData["name"] as! String
                                                let title0 = titleData.componentsSeparatedByString("-")
                                                let title = title0[0].componentsSeparatedByString("(")
                                                let duration = (resultData["duration_ms"] as! Int) / 1000
                                                let sURI = resultData["uri"] as! String
                                                var sugresult = spotifySearchResult()
                                                sugresult.artist = artist.trimSpaces()
                                                sugresult.track = title[0].trimSpaces()
                                                sugresult.duration = duration
                                                sugresult.spotifyURL = NSURL(string: sURL.trimSpaces())!
                                                sugresult.spotifyURI = NSURL(string: sURI.trimSpaces())!
                                                if !contains(suggestionResults, sugresult) {
                                                    suggestionResults.append(sugresult)
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                handler(suggestionResults)
                            })
                        }
                    } else if let jsonArtists = jsonResult["artists"] as? NSDictionary {
                        if let results:NSArray = jsonArtists["items"] as? NSArray {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.searching = false
                                var suggestionResults: [spotifySearchResult] = []
                                for result in results {
                                    let artist = result["name"] as! String
                                    var sugresult = spotifySearchResult()
                                    sugresult.artist = artist
                                    if !contains(suggestionResults, sugresult) {
                                        suggestionResults.append(sugresult)
                                    }
                                }
                                handler(suggestionResults)
                            })
                        }
                    }
                }
            })
            
            // The task is just an object with all these properties set
            // In order to actually make the web request, we need to "resume"
            self.searchTask.resume()
        }
    }
    
    
    func stopSearching() {
        self.searchTask.cancel()
        self.searching = false
    }
    
    
    func spotifySearchResultsToStringArray(results: [spotifySearchResult]) -> [String] {
        var stringResutls: [String] = []
        for result in results {
            if count(result.track)>1 {
                stringResutls.append(result.track + " (" + result.artist + ")")
            } else {
                stringResutls.append(result.artist)
            }
        }
        return stringResutls
    }
    
    

}
