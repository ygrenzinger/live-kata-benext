module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Array exposing (Array)
import Browser
import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type Cell
    = Empty
    | Cross
    | Circle


type alias Row =
    Array Cell


type alias Grid =
    Array Row


type alias Model =
    Grid


createGrid : Grid
createGrid =
    Array.repeat 3 (Array.repeat 3 Empty)


init : Model
init =
    createGrid



-- UPDATE


type Msg
    = None


update : Msg -> Model -> Model
update _ model =
    model



-- VIEW


buildCell : Cell -> Html Msg
buildCell _ =
    div
        [ css
            [ display inlineBlock
            , boxSizing borderBox
            , width (px 100)
            , height (pct 100)
            , border3 (px 2) solid (rgb 120 120 120)
            , hover
                [ borderColor (rgb 255 0 0)
                , borderRadius (px 10)
                ]
            ]
        ]
        []


buildRow : Row -> Html Msg
buildRow row =
    div
        [ css
            [ height (px 100)
            ]
        ]
        (Array.map buildCell row |> Array.toList)


buildPage : Model -> Html Msg
buildPage model =
    div [] (Array.map buildRow model |> Array.toList)


view : Model -> Html.Html Msg
view model =
    buildPage model |> toUnstyled
