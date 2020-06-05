module GameOfLife exposing (..)

import Array exposing (Array)
import Dict exposing (size)
import Html exposing (b)
import Set exposing (Set)
import String exposing (String, lines, trim)


type CellState
    = DEAD
    | ALIVE


type alias Position =
    ( Int, Int )


type alias Cells =
    Set Position


type Grid
    = Grid Int Cells


tick : CellState -> Int -> CellState
tick state nbOfAliveNeigbours =
    case ( state, nbOfAliveNeigbours ) of
        ( _, 3 ) ->
            ALIVE

        ( ALIVE, 2 ) ->
            ALIVE

        _ ->
            DEAD


initGrid : Int -> Set Position -> Grid
initGrid size cells =
    Grid size cells


killCell : Position -> Grid -> Grid
killCell pos (Grid size cells) =
    Grid size (Set.remove pos cells)


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
        gridLines : List (List Char)
        gridLines =
            lines s
                |> List.map trim
                |> List.filter (not << String.isEmpty)
                |> List.map String.toList

        convertRow : Int -> List Char -> List ( Position, CellState )
        convertRow i =
            List.indexedMap (\j char -> ( ( i, j ), convertChar char ))

        cells : Set Position
        cells =
            List.indexedMap convertRow gridLines
                |> List.concat
                |> List.filter (\( _, cellState ) -> cellState == ALIVE)
                |> List.map (\( pos, _ ) -> pos)
                |> Set.fromList

        size =
            gridLines |> List.length
    in
    initGrid size cells


cellAt : Grid -> Position -> CellState
cellAt (Grid _ cells) pos =
    if Set.member pos cells then
        ALIVE

    else
        DEAD


countAliveNeighbours : Grid -> Position -> Int
countAliveNeighbours grid pos =
    neighbours pos
        |> List.map (cellAt grid)
        |> List.filter ((==) ALIVE)
        |> List.length


neighbours : Position -> List Position
neighbours ( i, j ) =
    List.range -1 1
        |> List.concatMap (\ii -> List.range -1 1 |> List.map (\jj -> ( ii, jj )))
        |> List.map (\( ii, jj ) -> ( ii + i, jj + j ))
        |> List.filter ((/=) ( i, j ))
