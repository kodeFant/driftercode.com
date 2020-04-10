module Webmanifest exposing (manifest)

import Color
import Pages exposing (images, pages)
import Pages.Manifest as Manifest
import Pages.Manifest.Category


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = "DrifterCode - The great functional programming journey."
    , iarcRatingId = Nothing
    , name = "driftercode"
    , themeColor = Just Color.white
    , startUrl = pages.index
    , shortName = Just "driftercode"
    , sourceIcon = images.iconPng
    }
