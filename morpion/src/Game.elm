module Game exposing (Cell, CellPosition, CellState(..), Game(..), Grid, Player(..), Row, cellStateAt, createGrid, getGrid, getPlayer, isFull, selectCell, updateGrid)

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
    | Draw Player Grid


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

        Draw _ grid ->
            grid


updateGrid : Player -> CellPosition -> Grid -> Grid
updateGrid player pos grid =
    updateArrayWith (updateRow player pos.x) pos.y grid


cellStateAt : Grid -> CellPosition -> CellState
cellStateAt grid pos =
    Array.get pos.y grid
        |> Maybe.andThen (\row -> Array.get pos.x row)
        |> Maybe.map (\cell -> cell.state)
        |> Maybe.withDefault Empty


getPlayer : Game -> Player
getPlayer game =
    case game of
        Running player _ ->
            player

        Won player _ ->
            player

        Draw player _ ->
            player


switchPlayer : Player -> Player
switchPlayer player =
    case player of
        FirstPlayer ->
            SecondPlayer

        SecondPlayer ->
            FirstPlayer


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


allWinningPositions : List (List CellPosition)
allWinningPositions =
    List.concat [ columnsWinningPosition, rowsWinningPosition, diagonalsWinningPosition ]


positionIsOwnedBy : Grid -> CellPosition -> Maybe Player
positionIsOwnedBy grid position =
    case cellStateAt grid position of
        Cross ->
            Just FirstPlayer

        Circle ->
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
            if isFull (getGrid updatedGame) then
                Draw player (getGrid updatedGame)

            else
                updatedGame


isFull : Grid -> Bool
isFull grid =
    List.range 0 2
        |> List.concatMap (\y -> List.range 0 2 |> List.map (\x -> { x = x, y = y }))
        |> List.map (cellStateAt grid)
        |> List.all ((/=) Empty)


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
