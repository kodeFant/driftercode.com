module BlogIndex exposing (view)

import Date
import Design.Responsive exposing (responsiveView)
import Element
    exposing
        ( Element
        , alpha
        , centerX
        , centerY
        , column
        , el
        , fill
        , fillPortion
        , height
        , image
        , link
        , maximum
        , mouseOver
        , moveUp
        , padding
        , paragraph
        , rgba255
        , row
        , spacing
        , text
        , textColumn
        , width
        )
import Element.Border as Border
import Element.Font as Font
import Metadata exposing (Metadata(..))
import Pages
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath exposing (PagePath)
import Palette
import Util.Date exposing (formatDate)


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> Element msg
view posts =
    let
        filteredPosts : List (Element msg)
        filteredPosts =
            posts
                |> List.filterMap
                    (\( path, metadata ) ->
                        case metadata of
                            Metadata.Page _ ->
                                Nothing

                            Metadata.Author _ ->
                                Nothing

                            Metadata.Article meta ->
                                if meta.draft then
                                    Nothing

                                else
                                    Just ( path, meta )

                            Metadata.BlogIndex ->
                                Nothing
                    )
                |> List.sortWith
                    (\( _, metaA ) ( _, metaB ) -> Date.compare metaA.published metaB.published)
                |> List.reverse
                |> List.map postSummary
    in
    Element.column [ Element.spacing 20, padding 10, width (fill |> maximum 900) ]
        filteredPosts


postPreview : Metadata.ArticleMetadata -> Element msg
postPreview post =
    responsiveView
        { mobile = smallScreenPreview post
        , medium =
            smallScreenPreview post
        , large = largeScreenPreview post
        }


smallScreenPreview : Metadata.ArticleMetadata -> Element msg
smallScreenPreview post =
    textColumn
        [ centerX
        , width fill
        , spacing 10
        , Font.size 18
        ]
        [ image [ height fill, width fill ]
            { src = ImagePath.toString post.image
            , description = "Article cover photo"
            }
        , el [ Font.center ] (text (post.published |> formatDate))
        , title post.title
        , post.description
            |> text
            |> List.singleton
            |> paragraph
                [ Font.size 22
                , Font.center
                , Font.family [ Font.typeface "Open Sans" ]
                ]
        ]


largeScreenPreview : Metadata.ArticleMetadata -> Element msg
largeScreenPreview post =
    row [ spacing 16 ]
        [ column [ width (fillPortion 2) ]
            [ image [ centerY, width fill ]
                { src = ImagePath.toString post.image
                , description = "Article cover photo"
                }
            , post.description
                |> text
                |> List.singleton
                |> paragraph
                    [ Font.size 22
                    , Font.center
                    , Font.family [ Font.typeface "Open Sans" ]
                    , padding 20
                    ]
            , readMoreLink
            ]
        , textColumn
            [ centerX
            , width fill
            , spacing 30
            , width (fillPortion 2)
            ]
            [ el [ Font.center ] (text (post.published |> formatDate))
            , title post.title
            ]
        ]


postSummary :
    ( PagePath Pages.PathKey, Metadata.ArticleMetadata )
    -> Element msg
postSummary ( postPath, post ) =
    articleIndex post
        |> linkToPost postPath


linkToPost : PagePath Pages.PathKey -> Element msg -> Element msg
linkToPost postPath content =
    link [ width fill ]
        { url = PagePath.toString postPath, label = content }


title : String -> Element msg
title textString =
    [ text textString ]
        |> paragraph
            [ Font.size 38
            , Font.center
            , Font.family [ Font.typeface "Merriweather" ]
            , Font.semiBold
            , padding 16
            ]


articleIndex : Metadata.ArticleMetadata -> Element msg
articleIndex metadata =
    el
        [ centerX
        , padding 40
        , spacing 10
        , Border.width 1
        , Border.color (rgba255 0 0 0 0.1)
        , mouseOver
            [ Border.color Palette.color.primary
            , moveUp 5
            , Border.glow Palette.color.primary 2
            ]
        ]
        (postPreview metadata)


readMoreLink : Element msg
readMoreLink =
    text "Read the article >>"
        |> el
            [ centerX
            , Font.size 18
            , alpha 0.6
            , mouseOver [ alpha 1 ]
            , Font.underline
            , Font.center
            ]
