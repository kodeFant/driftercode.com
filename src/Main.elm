module Main exposing (main)

import Constants exposing (canonicalSiteUrl, siteTagline)
import ElmPages.Feed as Feed
import ElmPages.Sitemap as Sitemap
import ElmPages.Webmanifest exposing (manifest)
import Head.Metadata exposing (Metadata)
import Pages
import Pages.Document
import Pages.PagePath exposing (PagePath)
import Pages.Platform
import Renderer exposing (Rendered)
import Types exposing (Model, Msg(..))
import Update exposing (init, update)
import View exposing (view)



-- the intellij-elm plugin doesn't support type aliases for Programs so we need to use this line
-- main : Platform.Program Pages.Platform.Flags (Pages.Platform.Model Model Msg Metadata Rendered) (Pages.Platform.Msg Msg Metadata Rendered)


main : Pages.Platform.Program Model Msg Metadata (Rendered Msg)
main =
    Pages.Platform.application
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument ]
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        , onPageChange = \_ -> ChangedPage
        , internals = Pages.internals
        , generateFiles = generateFiles
        }


generateFiles :
    List
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        , body : String
        }
    ->
        List
            (Result String
                { path : List String
                , content : String
                }
            )
generateFiles siteMetadata =
    [ Feed.fileToGenerate { siteTagline = siteTagline, siteUrl = canonicalSiteUrl } siteMetadata |> Ok
    , Sitemap.build { siteUrl = canonicalSiteUrl } siteMetadata |> Ok
    ]


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata (Rendered Msg) )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Head.Metadata.decoder
        , body =
            \markdownBody ->
                Renderer.wordCountMarkdownView markdownBody
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
