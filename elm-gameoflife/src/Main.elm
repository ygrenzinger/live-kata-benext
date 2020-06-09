module Main exposing (Model, init, main, update, view)

import Browser
import GameOfLife exposing (CellState, Grid, Position, cellAt, emptyGrid, initGrid, makeAliveCell, randomGrid, tick)
import Html exposing (Attribute, Html, button, div, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Random exposing (generate)
import Set exposing (Set)
import Time


type Model
    = Paused Grid
    | Running Grid


type Msg
    = Tick Time.Posix
    | Reset
    | Start
    | Pause
    | MakeAlive ( Int, Int )
    | GenerateRandomGrid
    | RandomGridGenerated Grid


gridSize : Int
gridSize =
    40


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Paused (emptyGrid gridSize), Cmd.none )


tickGame : Model -> ( Model, Cmd Msg )
tickGame model =
    case model of
        Running grid ->
            ( Running (tick grid), Cmd.none )

        Paused _ ->
            ( model, Cmd.none )


makeAlive : Model -> Position -> ( Model, Cmd Msg )
makeAlive model pos =
    case model of
        Paused grid ->
            ( Paused (makeAliveCell pos grid), Cmd.none )

        Running _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            tickGame model

        Reset ->
            ( Paused (emptyGrid gridSize), Cmd.none )

        Start ->
            ( Running (getGrid model), Cmd.none )

        Pause ->
            ( Paused (getGrid model), Cmd.none )

        MakeAlive pos ->
            makeAlive model pos

        GenerateRandomGrid ->
            ( model
            , Random.generate RandomGridGenerated (randomGrid gridSize)
            )

        RandomGridGenerated grid ->
            ( Paused grid, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 500 Tick


displayCell : Grid -> Int -> Int -> Html Msg
displayCell grid i j =
    div
        [ style "background-color"
            (if cellAt grid ( i, j ) == GameOfLife.ALIVE then
                "#000"

             else
                "#fff"
            )
        , style "width" "20px"
        , style "height" "100%"
        , style "display" "inline-block"
        , style "border" "0.01em solid black"
        , onClick (MakeAlive ( i, j ))
        ]
        []


displayRow : Grid -> Int -> Html Msg
displayRow grid i =
    div
        [ style "margin" "0"
        , style "height" "20px"
        ]
        (List.range 1 gridSize |> List.map (displayCell grid i))


displayGrid : Grid -> Html Msg
displayGrid grid =
    div
        []
        (List.range 1 gridSize |> List.map (displayRow grid))


getGrid : Model -> Grid
getGrid game =
    case game of
        Running grid ->
            grid

        Paused grid ->
            grid


view : Model -> Html Msg
view model =
    div []
        [ div
            [ style "display" "inline-block"
            ]
            [ displayGrid (getGrid model) ]
        , div
            [ style "display" "inline-block"
            , style "vertical-align" "top"
            , style "text-align" "center"
            , style "width" "100px"
            ]
            [ button
                [ onClick Reset
                ]
                [ text "Reset" ]
            , button
                [ onClick Start
                ]
                [ text "Start" ]
            , button
                [ onClick Pause
                ]
                [ text "Pause" ]
            , button
                [ onClick GenerateRandomGrid
                ]
                [ text "Random" ]
            ]
        ]
