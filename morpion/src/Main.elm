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
createRow y =
    List.range 0 2 |> List.map (\x -> Cell x y Empty) |> Array.fromList


updateCell : CellState -> Cell -> Cell
updateCell state cell =
    { cell | state = state }


updateArrayWith : (a -> a) -> Int -> Array a -> Array a
updateArrayWith f index array =
    Array.get index array
        |> Maybe.map f
        |> Maybe.map (\x -> Array.set index x array)
        |> Maybe.withDefault array


updateRow : Int -> Row -> Row
updateRow x row =
    updateArrayWith (updateCell Cross) x row


createGrid : Grid
createGrid =
    List.range 0 2 |> List.map createRow |> Array.fromList



-- f : a -> b -> c
--(f a)=>(b -> c)=> (c)


updateGrid : Int -> Int -> Grid -> Grid
updateGrid x y grid =
    updateArrayWith (updateRow x) y grid


init : Model
init =
    createGrid



-- UPDATE


type Msg
    = Change Int Int


update : Msg -> Model -> Model
update (Change x y) model =
    updateGrid x y model



-- VIEW


buildCell : Cell -> Html Msg
buildCell cell =
    span
        [ css
            [ display inlineBlock
            , boxSizing borderBox
            , width (px 100)
            , height (px 100)
            , border3 (px 2) solid (rgb 120 120 120)
            , hover
                [ borderColor (rgb 255 0 0)
                , borderRadius (px 10)
                ]
            ]
        , onClick (Change cell.x cell.y)
        ]
        [ text
            (if cell.state == Cross then
                "x"

             else
                ""
            )
        ]


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
