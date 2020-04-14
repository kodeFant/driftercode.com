module View.BlogIndex exposing (view)

import Date
import Design.Palette as Palette
import Design.Responsive exposing (responsiveView)
import Element
    exposing
        ( Element
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
import Head.Metadata exposing (Metadata(..))
import Pages
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath exposing (PagePath)
import Util.Date exposing (formatDate)


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> List (Element msg)
    -> Element msg
view posts rendered =
    Element.column [ Element.spacing 20, padding 10, width (fill |> maximum 900) ]
        (textColumn
            [ centerX
            , padding 10
            , spacing 20
            , width (fill |> maximum 700)
            ]
            rendered
            :: postList posts
        )


postList : List ( PagePath Pages.PathKey, Metadata ) -> List (Element msg)
postList posts =
    posts
        |> List.filterMap
            (\( path, metadata ) ->
                case metadata of
                    Head.Metadata.Page _ ->
                        Nothing

                    Head.Metadata.Author _ ->
                        Nothing

                    Head.Metadata.Article meta ->
                        if meta.draft then
                            Nothing

                        else
                            Just ( path, meta )

                    Head.Metadata.BlogIndex ->
                        Nothing
            )
        |> List.sortWith
            (\( _, metaA ) ( _, metaB ) -> Date.compare metaA.published metaB.published)
        |> List.reverse
        |> List.map postSummary


postSummary :
    ( PagePath Pages.PathKey, Head.Metadata.ArticleMetadata )
    -> Element msg
postSummary ( postPath, post ) =
    articleIndex post
        |> linkToPost postPath


articleIndex : Head.Metadata.ArticleMetadata -> Element msg
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
        (listView metadata)


linkToPost : PagePath Pages.PathKey -> Element msg -> Element msg
linkToPost postPath content =
    link [ width fill ]
        { url = PagePath.toString postPath, label = content }


listView : Head.Metadata.ArticleMetadata -> Element msg
listView post =
    responsiveView []
        { mobile = listViewMobile post
        , medium =
            listViewMobile post
        , large = listViewLarge post
        }


listViewMobile : Head.Metadata.ArticleMetadata -> Element msg
listViewMobile post =
    textColumn
        [ centerX
        , width fill
        , spacing 10
        , Font.size 18
        ]
        [ image [ height fill, width fill ]
            { src = ImagePath.toString post.image
            , description = ""
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


listViewLarge : Head.Metadata.ArticleMetadata -> Element msg
listViewLarge post =
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
