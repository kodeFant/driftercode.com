module Head.Metadata exposing (ArticleMetadata, Index, Metadata(..), PageMetadata, decoder)

import Data.Author
import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)


type Metadata
    = Page PageMetadata
    | Article ArticleMetadata
    | Author Data.Author.Author
    | SiteIndex Index
    | BlogIndex


type alias Index =
    { title : String
    , subHeading : String
    , buttonText : String
    , buttonLink : String
    }


type alias ArticleMetadata =
    { title : String
    , description : String
    , published : Date
    , author : Data.Author.Author
    , image : ImagePath Pages.PathKey
    , draft : Bool
    , slug : String
    , tags : List String
    }


type alias PageMetadata =
    { title : String }


decoder : Decode.Decoder Metadata
decoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\pageType ->
                case pageType of
                    "page" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title -> Page { title = title })

                    "site-index" ->
                        Decode.map4 Index
                            (Decode.field "title" Decode.string)
                            (Decode.field "subHeading" Decode.string)
                            (Decode.field "buttonText" Decode.string)
                            (Decode.field "buttonLink" Decode.string)
                            |> Decode.map SiteIndex

                    "blog-index" ->
                        Decode.succeed BlogIndex

                    "author" ->
                        Decode.map5 Data.Author.Author
                            (Decode.field "name" Decode.string)
                            (Decode.field "avatar" imageDecoder)
                            (Decode.field "bio" Decode.string)
                            (Decode.field "twitter" Decode.string)
                            (Decode.field "linkedin" Decode.string)
                            |> Decode.map Author

                    "blog" ->
                        Decode.map8 ArticleMetadata
                            (Decode.field "title" Decode.string)
                            (Decode.field "description" Decode.string)
                            (Decode.field "published"
                                (Decode.string
                                    |> Decode.andThen
                                        (\isoString ->
                                            case Date.fromIsoString isoString of
                                                Ok date ->
                                                    Decode.succeed date

                                                Err error ->
                                                    Decode.fail error
                                        )
                                )
                            )
                            (Decode.field "author" Data.Author.decoder)
                            (Decode.field "image" imageDecoder)
                            (Decode.field "draft" Decode.bool
                                |> Decode.maybe
                                |> Decode.map (Maybe.withDefault False)
                            )
                            (Decode.field "slug" Decode.string)
                            (Decode.field "tags" (Decode.list Decode.string))
                            |> Decode.map Article

                    _ ->
                        Decode.fail <| "Unexpected page type " ++ pageType
            )


imageDecoder : Decoder (ImagePath Pages.PathKey)
imageDecoder =
    Decode.string
        |> Decode.andThen
            (\imageAssetPath ->
                case findMatchingImage imageAssetPath of
                    Nothing ->
                        Decode.fail "Couldn't find image."

                    Just imagePath ->
                        Decode.succeed imagePath
            )


findMatchingImage : String -> Maybe (ImagePath Pages.PathKey)
findMatchingImage imageAssetPath =
    Pages.allImages
        |> List.Extra.find
            (\image ->
                ImagePath.toString image
                    == imageAssetPath
            )
