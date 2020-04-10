module Util.Error exposing (errorToString)

import Http exposing (Error(..))


errorToString : Error -> String
errorToString error =
    case error of
        BadUrl string ->
            "You did not provide a valid URL: " ++ string

        Timeout ->
            "Connection timed out"

        NetworkError ->
            "Network Error. Please check your internet connection and try again"

        BadStatus int ->
            case int of
                400 ->
                    "Error 400: Validation error. Please make sure you sent correctly formatted information"

                code ->
                    "Error " ++ String.fromInt code

        BadBody string ->
            "Unexpected response: " ++ string
