module Game exposing (Cell, CellPosition, CellState(..), Game(..), Grid, Player(..), Row, createGrid, getGrid, getPlayer, selectCell, updateGrid)

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


type Player
    = FirstPlayer
    | SecondPlayer


type Game
    = Running Player Grid
    | Won Player Grid


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


getGrid : Game -> Grid
getGrid game =
    case game of
        Running _ grid ->
            grid

        Won _ grid ->
            grid


updateGrid : Player -> CellPosition -> Grid -> Grid
updateGrid player pos grid =
    updateArrayWith (updateRow player pos.x) pos.y grid


cellStateAt : CellPosition -> Grid -> Maybe CellState
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


columnsWinningPosition : List (List CellPosition)
columnsWinningPosition =
    List.range 0 2
        |> List.map (\x -> List.range 0 2 |> List.map (\y -> { x = x, y = y }))


rowsWinningPosition : List (List CellPosition)
rowsWinningPosition =
    List.range 0 2
        |> List.map (\y -> List.range 0 2 |> List.map (\x -> { x = x, y = y }))


diagonalsWinningPosition : List (List CellPosition)
diagonalsWinningPosition =
    let
        leftToRight =
            List.range 0 2
                |> List.map (\i -> { x = i, y = i })

        rightToLeft =
            List.range 2 0
                |> List.map (\i -> { x = i, y = i })
    in
    [ leftToRight, rightToLeft ]


allWinningPositions : List (List CellPosition)
allWinningPositions =
    List.concat [ columnsWinningPosition, rowsWinningPosition, diagonalsWinningPosition ]


positionIsOwnedBy : Grid -> CellPosition -> Maybe Player
positionIsOwnedBy grid position =
    case cellStateAt position grid of
        Just Cross ->
            Just FirstPlayer

        Just Circle ->
            Just SecondPlayer

        _ ->
            Nothing


positionsAreOwnedBy : Grid -> List CellPosition -> Maybe Player
positionsAreOwnedBy grid positions =
    let
        listMaybePlayer : List (Maybe Player)
        listMaybePlayer =
            List.map (positionIsOwnedBy grid) positions

        first : Maybe Player
        first =
            List.head listMaybePlayer |> Maybe.withDefault Nothing

        result =
            List.all ((==) first) listMaybePlayer
    in
    if result then
        first

    else
        Nothing


hasWinner : Grid -> Maybe Player
hasWinner grid =
    allWinningPositions
        |> List.map (positionsAreOwnedBy grid)
        |> List.filter ((/=) Nothing)
        |> List.head
        |> Maybe.withDefault Nothing


playerTurn : CellPosition -> Player -> Grid -> Game
playerTurn pos player grid =
    let
        nextPlayer =
            switchPlayer player

        updatedGame =
            Running nextPlayer (updateGrid player pos grid)

        winner =
            hasWinner (getGrid updatedGame)
    in
    case winner of
        Just _ ->
            Won player (getGrid updatedGame)

        Nothing ->
            updatedGame


selectCell : CellPosition -> Game -> Game
selectCell pos game =
    case game of
        (Running player grid) as runningGame ->
            if cellStateAt pos grid == Just Empty then
                playerTurn pos player grid

            else
                runningGame

        _ ->
            game
