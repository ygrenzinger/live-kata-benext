module GameOfLife exposing (..)

import Array exposing (empty, toList)
import Random exposing (int, pair)
import Random.Extra exposing (sequence)
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


tickCell : CellState -> Int -> CellState
tickCell state nbOfAliveNeigbours =
    case ( state, nbOfAliveNeigbours ) of
        ( _, 3 ) ->
            ALIVE

        ( ALIVE, 2 ) ->
            ALIVE

        _ ->
            DEAD


randomGrid : Int -> Random.Generator Grid
randomGrid size =
    let
        intToCellState : Int -> CellState
        intToCellState i =
            case i of
                1 ->
                    ALIVE

                _ ->
                    DEAD

        randomCell : Position -> Random.Generator ( CellState, Position )
        randomCell pos =
            int 0 1 |> Random.map intToCellState |> Random.map (\c -> ( c, pos ))

        cells : Random.Generator (Set Position)
        cells =
            allPossiblePositions size
                |> List.map randomCell
                |> sequence
                |> Random.map (\l -> l |> List.filter (\( c, pos ) -> c == ALIVE) |> List.map (\( _, pos ) -> pos))
                |> Random.map Set.fromList
    in
    Random.map (initGrid size) cells


emptyGrid : Int -> Grid
emptyGrid size =
    initGrid size Set.empty


initGrid : Int -> Set Position -> Grid
initGrid size cells =
    Grid size cells


killCell : Position -> Grid -> Grid
killCell pos (Grid size cells) =
    Grid size (Set.remove pos cells)


makeAliveCell : Position -> Grid -> Grid
makeAliveCell pos (Grid size cells) =
    Grid size (Set.insert pos cells)


tick : Grid -> Grid
tick grid =
    let
        (Grid size cells) =
            grid

        allNeighboursPositions : List Position
        allNeighboursPositions =
            cells |> Set.toList |> List.concatMap neighbours

        nextCellStateAtPosition : Position -> ( Position, CellState )
        nextCellStateAtPosition pos =
            let
                cell =
                    cellAt grid pos

                nextCell =
                    tickCell cell (countAliveNeighbours grid pos)
            in
            ( pos, nextCell )

        updatedCells =
            allNeighboursPositions
                |> List.map nextCellStateAtPosition
                |> List.filter (\( pos, cell ) -> cell == ALIVE)
                |> List.map (\( pos, _ ) -> pos)
                |> Set.fromList
    in
    Grid size updatedCells


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


allPossiblePositions : Int -> List Position
allPossiblePositions size =
    List.range 0 (size - 1)
        |> List.concatMap (\i -> List.range 0 (size - 1) |> List.map (\j -> ( i, j )))


fullGrid : Int -> Grid
fullGrid size =
    Grid size (allPossiblePositions size |> Set.fromList)
