module Grid exposing (Cell, CellPosition, CellState(..), Grid, Row, allPossiblePositions, cellStateAt, createGrid, isFull, positionsAreOwnedBy, updateGrid)

import Array exposing (Array)


type CellState
    = Empty
    | Cross
    | Circle


type alias Cell =
    { position : CellPosition
    , state : CellState
    }


type alias CellPosition =
    { x : Int
    , y : Int
    }


type alias Row =
    Array Cell


type alias Grid =
    Array Row


createGrid : Grid
createGrid =
    List.range 0 2 |> List.map createRow |> Array.fromList


updateGrid : CellState -> CellPosition -> Grid -> Grid
updateGrid player pos grid =
    updateArrayWith (updateRow player pos.x) pos.y grid


allPossiblePositions : List CellPosition
allPossiblePositions =
    List.range 0 2
        |> List.concatMap (\y -> List.range 0 2 |> List.map (\x -> { x = x, y = y }))


isFull : Grid -> Bool
isFull grid =
    allPossiblePositions
        |> List.map (cellStateAt grid)
        |> List.all ((/=) Empty)


positionsAreOwnedBy : Grid -> List CellPosition -> Maybe CellState
positionsAreOwnedBy grid positions =
    let
        listMaybePlayer : List CellState
        listMaybePlayer =
            List.map (cellStateAt grid) positions

        first : CellState
        first =
            List.head listMaybePlayer |> Maybe.withDefault Empty

        result =
            List.all ((==) first) listMaybePlayer
    in
    if result then
        Just first

    else
        Nothing


cellStateAt : Grid -> CellPosition -> CellState
cellStateAt grid pos =
    Array.get pos.y grid
        |> Maybe.andThen (\row -> Array.get pos.x row)
        |> Maybe.map (\cell -> cell.state)
        |> Maybe.withDefault Empty


createRow : Int -> Row
createRow y =
    List.range 0 2 |> List.map (\x -> Cell { x = x, y = y } Empty) |> Array.fromList


updateRow : CellState -> Int -> Row -> Row
updateRow state x row =
    updateArrayWith (updateCell state) x row


updateCell : CellState -> Cell -> Cell
updateCell state cell =
    { cell | state = state }


updateArrayWith : (a -> a) -> Int -> Array a -> Array a
updateArrayWith f index array =
    Array.get index array
        |> Maybe.map f
        |> Maybe.map (\x -> Array.set index x array)
        |> Maybe.withDefault array
