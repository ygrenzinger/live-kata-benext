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


type Player
    = FirstPlayer
    | SecondPlayer


type Game
    = Game Player Grid


type alias Model =
    Game


createRow : Int -> Row
createRow y =
    List.range 0 2 |> List.map (\x -> Cell x y Empty) |> Array.fromList


updateCell : Player -> Cell -> Cell
updateCell player cell =
    { cell | state = cellStateForPlayer player }


updateArrayWith : (a -> a) -> Int -> Array a -> Array a
updateArrayWith f index array =
    Array.get index array
        |> Maybe.map f
        |> Maybe.map (\x -> Array.set index x array)
        |> Maybe.withDefault array


updateRow : Player -> Int -> Row -> Row
updateRow player x row =
    updateArrayWith (updateCell player) x row


cellStateForPlayer : Player -> CellState
cellStateForPlayer player =
    case player of
        FirstPlayer ->
            Cross

        SecondPlayer ->
            Circle


createGrid : Grid
createGrid =
    List.range 0 2 |> List.map createRow |> Array.fromList



-- f : a -> b -> c
--(f a)=>(b -> c)=> (c)


updateGrid : Player -> Int -> Int -> Grid -> Grid
updateGrid player x y grid =
    updateArrayWith (updateRow player x) y grid


cellStateAt : Int -> Int -> Grid -> Maybe CellState
cellStateAt x y grid =
    Array.get y grid
        |> Maybe.andThen (\row -> Array.get x row)
        |> Maybe.map (\cell -> cell.state)


switchPlayer : Player -> Player
switchPlayer player =
    case player of
        FirstPlayer ->
            SecondPlayer

        SecondPlayer ->
            FirstPlayer


playerTurn : Int -> Int -> Game -> Game
playerTurn x y (Game player grid) =
    if cellStateAt x y grid == Just Empty then
        Game (switchPlayer player) (updateGrid player x y grid)

    else
        Game player grid


init : Model
init =
    Game FirstPlayer createGrid



-- UPDATE


type Msg
    = Change Int Int


update : Msg -> Model -> Model
update (Change x y) game =
    playerTurn x y game



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
        , onClick (Change cell.x cell.y)
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


buildPage : Model -> Html Msg
buildPage (Game _ grid) =
    div
        []
        (Array.map buildRow grid |> Array.toList)


view : Model -> Html.Html Msg
view model =
    buildPage model |> toUnstyled
