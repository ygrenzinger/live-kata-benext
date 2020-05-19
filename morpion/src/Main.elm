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


type CellState
    = Empty
    | Cross
    | Circle


type alias Cell =
    { x : Int
    , y : Int
    , state : CellState
    }


type alias Row =
    Array Cell


type alias Grid =
    Array Row


type alias Model =
    Grid


createRow : Int -> Row
createRow rowIndex =
    List.range 0 2 |> List.map (\columnIndex -> Cell columnIndex rowIndex Empty) |> Array.fromList


updateCell : CellState -> Cell -> Cell
updateCell state cell =
    { cell | state = state }



-- Maybe a -> Maybe.map (a -> b) a -> Maybe b


upateArrayWith : (a -> a) -> Int -> Array a -> Maybe (Array a)
upateArrayWith f index array =
    Array.get index array
        |> Maybe.map f
        |> Maybe.map (\x -> Array.set index x array)


updateRow : Int -> Row -> Row
updateRow columnIndex row =
    let
        maybeCell : Maybe Cell
        maybeCell =
            Array.get columnIndex row

        maybeUpdatedCell : Maybe Cell
        maybeUpdatedCell =
            Maybe.map (updateCell Cross) maybeCell
    in
    maybeUpdatedCell |> Maybe.map (\c -> Array.set columnIndex c row) |> Maybe.withDefault row


createGrid : Grid
createGrid =
    List.range 0 2 |> List.map createRow |> Array.fromList


updateGrid : Int -> Int -> Grid -> Grid
updateGrid rowIndex columnIndex grid =
    Array.get rowIndex grid


init : Model
init =
    createGrid



-- UPDATE


type Msg
    = Change Int Int


update : Msg -> Model -> Model
update (Change x y) model =
    model



-- VIEW


buildCell : Cell -> Html Msg
buildCell cell =
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
        , onClick (Change cell.x cell.y)
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
