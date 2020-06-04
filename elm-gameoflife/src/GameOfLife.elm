module GameOfLife exposing (..)

import Array exposing (Array)
import String exposing (String, lines, trim)


type CellState
    = DEAD
    | ALIVE


tick : CellState -> Int -> CellState
tick state nbOfAliveNeigbours =
    case ( state, nbOfAliveNeigbours ) of
        ( _, 3 ) ->
            ALIVE

        ( ALIVE, 2 ) ->
            ALIVE

        _ ->
            DEAD


type alias Grid =
    Array CellState


initGrid : CellState -> Int -> Grid
initGrid state size =
    Array.repeat (size * size) state


convertChar : Char -> CellState
convertChar c =
    case c of
        '1' ->
            ALIVE

        _ ->
            DEAD


fromString : String -> Grid
fromString s =
    let
        gridLines =
            lines s |> List.map trim |> List.filter (not << String.isEmpty)

        firstChar : Char
        firstChar =
            List.head gridLines |> Maybe.map String.toList |> Maybe.andThen List.head |> Maybe.withDefault '0'

        size =
            gridLines |> List.length
    in
    initGrid (convertChar firstChar) size


computeAliveNeighbours : Grid -> ( Int, Int ) -> Int
computeAliveNeighbours _ _ =
    0
