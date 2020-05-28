module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Array exposing (Array)
import Browser
import Css exposing (..)
import Game exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    Game


init : Model
init =
    Running FirstPlayer createGrid



-- UPDATE


type Msg
    = Change Game.Position


update : Msg -> Model -> Model
update (Change pos) game =
    playerTurn pos game



-- VIEW
-- style="display:flex;justify-content:center;align-items:center;"


symbolForState : CellState -> String
symbolForState cellState =
    case cellState of
        Cross ->
            "x"

        Circle ->
            "o"

        Empty ->
            ""


buildCell : Cell -> Html Msg
buildCell cell =
    div
        [ css
            [ display inlineBlock
            , verticalAlign middle
            , textAlign center
            , boxSizing borderBox
            , width (px 100)
            , height (pct 100)
            , fontSize (px 50)
            , fontWeight bold
            , border3 (px 2) solid (rgb 120 120 120)
            , hover
                [ borderColor (rgb 255 0 0)
                , borderRadius (px 10)
                ]
            ]
        , onClick (Change cell.position)
        ]
        [ text <| symbolForState cell.state
        ]


buildRow : Row -> Html Msg
buildRow row =
    div
        [ css
            [ height (px 100)
            , lineHeight (px 100)
            ]
        ]
        (Array.map buildCell row |> Array.toList)


buildGrid : Grid -> Html Msg
buildGrid grid =
    div
        []
        (Array.map buildRow grid |> Array.toList)


buildPage : Model -> Html Msg
buildPage game =
    case game of
        Running _ grid ->
            buildGrid grid

        Won _ grid ->
            buildGrid grid


view : Model -> Html.Html Msg
view model =
    buildPage model |> toUnstyled
