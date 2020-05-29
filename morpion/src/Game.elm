module Game exposing (Game(..), Player(..), getGrid, getPlayer, selectCell)

import Grid exposing (CellPosition, CellState(..), Grid, cellStateAt, isFull, positionsAreOwnedBy, updateGrid)


type Player
    = CrossPlayer
    | CirclePlayer
    | None


type Game
    = Running Player Grid
    | Won Player Grid
    | Draw Grid


getGrid : Game -> Grid
getGrid game =
    case game of
        Running _ grid ->
            grid

        Won _ grid ->
            grid

        Draw grid ->
            grid


getPlayer : Game -> Player
getPlayer game =
    case game of
        Running player _ ->
            player

        Won player _ ->
            player

        Draw _ ->
            None


selectCell : CellPosition -> Game -> Game
selectCell pos game =
    case game of
        (Running player grid) as runningGame ->
            if cellStateAt grid pos == Empty then
                playerTurn pos player grid

            else
                runningGame

        _ ->
            game


playerTurn : CellPosition -> Player -> Grid -> Game
playerTurn pos player grid =
    let
        updatedGrid =
            updateGrid (cellStateForPlayer player) pos grid
    in
    case hasWinner updatedGrid of
        None ->
            if isFull updatedGrid then
                Draw updatedGrid

            else
                Running (switchPlayer player) updatedGrid

        winner ->
            Won winner updatedGrid


switchPlayer : Player -> Player
switchPlayer player =
    case player of
        CrossPlayer ->
            CirclePlayer

        CirclePlayer ->
            CrossPlayer

        _ ->
            None


hasWinner : Grid -> Player
hasWinner grid =
    let
        playerForCellState state =
            case state of
                Just Cross ->
                    CrossPlayer

                Just Circle ->
                    CirclePlayer

                _ ->
                    None
    in
    allWinningPositions
        |> List.map (positionsAreOwnedBy grid)
        |> List.map playerForCellState
        |> List.filter ((/=) None)
        |> List.head
        |> Maybe.withDefault None


cellStateForPlayer : Player -> CellState
cellStateForPlayer player =
    case player of
        CrossPlayer ->
            Cross

        CirclePlayer ->
            Circle

        None ->
            Empty


allWinningPositions : List (List CellPosition)
allWinningPositions =
    List.concat [ columnsWinningPosition, rowsWinningPosition, diagonalsWinningPosition ]


buildWinningPosition : (Int -> Int -> CellPosition) -> List (List CellPosition)
buildWinningPosition f =
    List.range 0 2
        |> List.map (\x -> List.range 0 2 |> List.map (f x))


columnsWinningPosition : List (List CellPosition)
columnsWinningPosition =
    buildWinningPosition (\x y -> { x = x, y = y })


rowsWinningPosition : List (List CellPosition)
rowsWinningPosition =
    buildWinningPosition (\x y -> { x = y, y = x })


diagonalsWinningPosition : List (List CellPosition)
diagonalsWinningPosition =
    let
        leftToRight =
            List.range 0 2
                |> List.map (\i -> { x = i, y = i })

        rightToLeft =
            [ { x = 2, y = 0 }, { x = 1, y = 1 }, { x = 0, y = 2 } ]
    in
    [ leftToRight, rightToLeft ]
