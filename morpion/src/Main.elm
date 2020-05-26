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
    { position : Position
    , state : CellState
    }


type alias Position =
    { x : Int
    , y : Int
    }


type alias Row =
    Array Cell


type alias Grid =
    Array Row


type Player
    = FirstPlayer
    | SecondPlayer


type Game
    = Running Player Grid
    | Won Player Grid


type alias Model =
    Game


createRow : Int -> Row
createRow y =
    List.range 0 2 |> List.map (\x -> Cell { x = x, y = y } Empty) |> Array.fromList


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


getGrid : Game -> Grid
getGrid game =
    case game of
        Running _ grid ->
            grid

        Won _ grid ->
            grid


updateGrid : Player -> Position -> Grid -> Grid
updateGrid player pos grid =
    updateArrayWith (updateRow player pos.x) pos.y grid


cellStateAt : Position -> Grid -> Maybe CellState
cellStateAt pos grid =
    Array.get pos.y grid
        |> Maybe.andThen (\row -> Array.get pos.x row)
        |> Maybe.map (\cell -> cell.state)


getPlayer : Game -> Player
getPlayer game =
    case game of
        Running player _ ->
            player

        Won player _ ->
            player


switchPlayer : Player -> Player
switchPlayer player =
    case player of
        FirstPlayer ->
            SecondPlayer

        SecondPlayer ->
            FirstPlayer



-- winsPosition
-- isPlayerWon : Player -> Grid -> Boolean
-- isPlayerWon player grid =


playerTurn : Position -> Game -> Game
playerTurn pos game =
    case game of
        Running player grid ->
            if cellStateAt pos grid == Just Empty then
                Running (switchPlayer player) (updateGrid player pos grid)

            else
                Running player grid

        _ ->
            game


init : Model
init =
    Running FirstPlayer createGrid



-- UPDATE


type Msg
    = Change Position


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
