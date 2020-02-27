module Types exposing (Model, Msg(..))


type Msg
    = NoOp
    | ToggleMobileMenu
    | ChangedPage


type alias Model =
    { mobileMenuVisible : Bool
    }
