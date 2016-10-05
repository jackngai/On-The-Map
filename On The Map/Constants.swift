//
//  Constants.swift
//  On The Map
//
//  Created by Jack Ngai on 9/30/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import Foundation

struct Constants{
    

    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
        
        // MARK: Movies
        static let MovieID = "id"
        static let MovieTitle = "title"
        static let MoviePosterPath = "poster_path"
        static let MovieReleaseDate = "release_date"
        static let MovieReleaseYear = "release_year"
        static let MovieResults = "results"
        static let MovieRating = "vote_average"
        
    }

    
    struct Parse{
        static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIkey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        struct Methods{
            static let baseURL = "https://parse.udacity.com/parse/classes/StudentLocation"
        }
        
        struct ParameterKeys {
            static let limit = "limit"
            static let skip = "skip"
            static let order = "order"
            static let Where = "where"
        }
    }
    
    struct Udacity{
        static let sessionMethod = "/session"
        static let userinfoMethod = "/users/"
        
        // MARK: Udacity URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        
        struct ParameterKeys {
            static let udacity = "udacity"
            static let user = "username"
            static let pw = "password"
        }
        

    }
    
}

// MARK: Methods
struct Methods {
    
    // MARK: Account
    static let Account = "/account"
    static let AccountIDFavoriteMovies = "/account/{id}/favorite/movies"
    static let AccountIDFavorite = "/account/{id}/favorite"
    static let AccountIDWatchlistMovies = "/account/{id}/watchlist/movies"
    static let AccountIDWatchlist = "/account/{id}/watchlist"
    
    // MARK: Authentication
    static let AuthenticationTokenNew = "/authentication/token/new"
    static let AuthenticationSessionNew = "/authentication/session/new"
    
    // MARK: Search
    static let SearchMovie = "/search/movie"
    
    // MARK: Config
    static let Config = "/configuration"
    
}