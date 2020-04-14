module Data.Author exposing (Author, all, decoder, defaultAuthor, elmUIView, view)

import Element exposing (Element)
import Html exposing (Html)
import Html.Attributes as Attr
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
    , bio = "Developer and digital storyteller. Works as a frontend developer at Kantega."
    , twitter = "larsparsfromage"
    , linkedinUrl = "https://www.linkedin.com/in/larslilloulvestad/"
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


elmUIView : List (Element.Attribute msg) -> Author -> Element msg
elmUIView attributes author =
    Element.image
        (Element.width (Element.px 70)
            :: Element.htmlAttribute (Attr.class "avatar")
            :: attributes
        )
        { src = ImagePath.toString author.avatar, description = author.name }


view : List (Html.Attribute msg) -> Author -> Html msg
view attributes author =
    Styled.image (attributes ++ []) { description = author.name, path = ImagePath.toString author.avatar }
