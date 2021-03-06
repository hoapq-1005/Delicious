//
//  FavoriteRecipe.swift
//  Delicious
//
//  Created by HoaPQ on 8/3/20.
//  Copyright © 2020 HoaPQ. All rights reserved.
//

import Foundation

struct FavoriteRecipe: RecipeType {
    var id: Int
    var title: String
    var readyInMinutes: Int
    var servings: Int
    var image: String
    var creditsText: String
}

extension FavoriteRecipe: IdentifiableType, Equatable {
    var identity: Int {
        return id
    }
    
    static func == (lhs: FavoriteRecipe, rhs: FavoriteRecipe) -> Bool {
        return lhs.id == rhs.id
    }
}

extension FavoriteRecipe: CoreDataModel {
    static var primaryKey: String {
        return "id"
    }
    
    var modelID: Int {
        return id
    }
}

extension FavoriteRecipe {
    init(from type: RecipeType) {
        id = type.id
        title = type.title
        readyInMinutes = type.readyInMinutes
        servings = type.servings
        image = type.image
        creditsText = type.creditsText
    }
}
