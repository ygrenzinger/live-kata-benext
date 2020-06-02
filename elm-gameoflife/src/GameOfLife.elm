module GameOfLife exposing (..)


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
