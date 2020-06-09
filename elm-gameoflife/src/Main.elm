module Main exposing (Model, init, main, update, view)

import Browser
import GameOfLife exposing (Grid, emptyGrid, tick)
import Html exposing (Html, button, div, span, text)
import Html.Events exposing (onClick)
import Time


type Model
    = Paused Grid
    | Running Grid


gridSize : Int
gridSize =
    50


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


type Msg
    = Tick Time.Posix
    | Reset
    | Start
    | Pause


tickGame : Model -> ( Model, Cmd Msg )
tickGame model =
    case model of
        Running grid ->
            ( Running (tick grid), Cmd.none )

        Paused _ ->
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


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 Tick


displayCell : Grid -> Int -> Int -> Html Msg
displayCell grid i j =
    span []
        [ text "0"
        ]


displayRow : Grid -> Int -> Html Msg
displayRow grid i =
    div []
        (List.range 1 gridSize |> List.map (displayCell grid i))


displayGrid : Grid -> Html Msg
displayGrid grid =
    div []
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
        [ button [ onClick Reset ] [ text "Reset" ]
        , button [ onClick Start ] [ text "Start" ]
        , button [ onClick Pause ] [ text "Pause" ]
        , div [] [ displayGrid (getGrid model) ]
        ]
