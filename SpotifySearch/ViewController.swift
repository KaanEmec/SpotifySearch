//
//  ViewController.swift
//  SpotifySearch
//
//  Created by Kaan on 19.08.2016.
//  Copyright © 2016 Kaan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let minSearchInterval: NSTimeInterval = NSTimeInterval(1.0)
    var webSearchStartTime: NSDate!
    var refreshSearchTimer: NSTimer!

    var suggestions: [spotifySearchResult]!
    var SpotifySearch = spotifySearch()
    
    @IBOutlet weak var resultsField: UITextView!
    @IBOutlet weak var searchField: UITextField!
    
    
    @IBAction func textEditing(sender: UITextField, forEvent event: UIEvent) {
        
        if searchField.text?.characters.count>2 {
            print(searchField.text)
            if SpotifySearch.searching {
                if NSDate().timeIntervalSinceDate(webSearchStartTime) > minSearchInterval {
                    if refreshSearchTimer != nil { refreshSearchTimer.invalidate() }
                    SpotifySearch.stopSearching()
                    SpotifySearch.searchSpotifyFor(sender.text!, searchType: spotifySearchType.Song, handler: self.handleSongResults)
                    webSearchStartTime = NSDate()
                } else {
                    if refreshSearchTimer != nil { refreshSearchTimer.invalidate() }
                    refreshSearchTimer = NSTimer.scheduledTimerWithTimeInterval(minSearchInterval - NSDate().timeIntervalSinceDate(webSearchStartTime), target: self, selector: #selector(self.refreshSongSearch), userInfo: nil, repeats: false)
                }
            } else {
                if refreshSearchTimer != nil { refreshSearchTimer.invalidate() }
                SpotifySearch.searchSpotifyFor(self.searchField.text!, searchType: spotifySearchType.Song, handler: self.handleSongResults)
                webSearchStartTime = NSDate()
            }
        } else {
            if SpotifySearch.searching { SpotifySearch.stopSearching() }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func handleSongResults(results: [spotifySearchResult]) {
        if results.count > 0 {
            resultsField.text = ""
            if SpotifySearch.searching { SpotifySearch.stopSearching() }
            if refreshSearchTimer != nil { refreshSearchTimer.invalidate() }
            
            for eachResult in results {
                resultsField.text = resultsField.text + eachResult.artist + " - " + eachResult.track + "\n\n"
            }
        }
    }
    
    
    func refreshSongSearch() {
        if SpotifySearch.searching { SpotifySearch.stopSearching() }
        SpotifySearch.searchSpotifyFor(searchField.text!, searchType: spotifySearchType.Song, handler: self.handleSongResults)
    }

}

