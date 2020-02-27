module Update exposing (update)

import Types exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ChangedPage ->
            ( { model | mobileMenuVisible = False }, Cmd.none )

        ToggleMobileMenu ->
            ( { model | mobileMenuVisible = not model.mobileMenuVisible }, Cmd.none )
