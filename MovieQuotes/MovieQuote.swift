//
//  MovieQuote.swift
//  MovieQuotes
//
//  Created by FengYizhi on 2018/3/29.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit

class MovieQuote: NSObject {
    var quote: String
    var movie: String
    
    init(quote: String, movie: String) {
        self.quote = quote
        self.movie = movie
    }
}
