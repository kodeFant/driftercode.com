module Data.Author exposing (Author, all, decoder, defaultAuthor, view)

import Constants
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Styled


type alias Author =
    { name : String
    , avatar : ImagePath Pages.PathKey
    , bio : String
    , twitter : String
    , linkedinUrl : String
    }


defaultAuthor : Author
defaultAuthor =
    { name = "Lars Lillo Ulvestad"
    , avatar = Pages.images.author.lillo
    , bio = "Developer and digital storyteller. Works as a front-end developer at Kantega."
    , twitter = Constants.siteTwitter
    , linkedinUrl = Constants.siteLinkedIn
    }


all : List Author
all =
    [ defaultAuthor ]


decoder : Decoder Author
decoder =
    Decode.string
        |> Decode.andThen
            (\lookupName ->
                case List.Extra.find (\currentAuthor -> currentAuthor.name == lookupName) all of
                    Just author ->
                        Decode.succeed author

                    Nothing ->
                        Decode.fail ("Couldn't find author with name " ++ lookupName ++ ". Options are " ++ String.join ", " (List.map .name all))
            )


view : List (Attribute msg) -> Author -> Html msg
view attributes author =
    Styled.image
        (attributes
            ++ [ css
                    [ borderRadius (pct 50)
                    , maxWidth (px 70)
                    ]
               ]
        )
        { description = author.name, path = ImagePath.toString author.avatar }
