module Main exposing (main)

import Feed
import MarkdownRenderer exposing (Rendered)
import Metadata exposing (Metadata)
import MySitemap
import Pages
import Pages.Document
import Pages.PagePath exposing (PagePath)
import Pages.Platform
import Types exposing (Model, Msg(..))
import Update exposing (init, update)
import View exposing (view)
import Webmanifest exposing (manifest)



-- the intellij-elm plugin doesn't support type aliases for Programs so we need to use this line
-- main : Platform.Program Pages.Platform.Flags (Pages.Platform.Model Model Msg Metadata Rendered) (Pages.Platform.Msg Msg Metadata Rendered)


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://driftercode.com/"


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
    , MySitemap.build { siteUrl = canonicalSiteUrl } siteMetadata |> Ok
    ]


siteTagline : String
siteTagline =
    "DrifterCode - The Great Functional Programming Journey"


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata (Rendered Msg) )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Metadata.decoder
        , body =
            \markdownBody ->
                MarkdownRenderer.wordCountMarkdownView markdownBody
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
