module Game exposing (Cell, CellState(..), Game(..), Grid, Player(..), Position, Row, cellStateAt, cellStateForPlayer, createGrid, createRow, getGrid, getPlayer, playerTurn, switchPlayer, updateArrayWith, updateCell, updateGrid, updateRow)

import Array exposing (Array)


type CellState
    = Empty
    | Cross
    | Circle


type alias Cell =
    { position : Position
    , state : CellState
    }


type alias Position =
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



-- f : a -> b -> c
--(f a)=>(b -> c)=> (c)


getGrid : Game -> Grid
getGrid game =
    case game of
        Running _ grid ->
            grid

        Won _ grid ->
            grid


updateGrid : Player -> Position -> Grid -> Grid
updateGrid player pos grid =
    updateArrayWith (updateRow player pos.x) pos.y grid


cellStateAt : Position -> Grid -> Maybe CellState
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


columnsWinningPosition : List (List Position)
columnsWinningPosition =
    List.range 0 2
        |> List.map (\x -> List.range 0 2 |> List.map (\y -> { x = x, y = y }))


rowsWinningPosition : List (List Position)
rowsWinningPosition =
    List.range 0 2
        |> List.map (\y -> List.range 0 2 |> List.map (\x -> { x = x, y = y }))


diagonalsWinningPosition : List (List Position)
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


allWinningPositions : List (List Position)
allWinningPositions =
    List.concat [ columnsWinningPosition, rowsWinningPosition, diagonalsWinningPosition ]


positionIsOwnedBy : Grid -> Position -> Maybe Player
positionIsOwnedBy grid position =
    case cellStateAt position grid of
        Just Cross ->
            Just FirstPlayer

        Just Circle ->
            Just SecondPlayer

        _ ->
            Nothing


positionsAreOwnedBy : Grid -> List Position -> Maybe Player
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


playerTurn : Position -> Game -> Game
playerTurn pos game =
    case game of
        Running player grid ->
            let
                updatedGame =
                    if cellStateAt pos grid == Just Empty then
                        Running (switchPlayer player) (updateGrid player pos grid)

                    else
                        Running player grid

                winner =
                    hasWinner (getGrid updatedGame)
            in
            case winner of
                Just _ ->
                    Won player (getGrid updatedGame)

                Nothing ->
                    updatedGame

        _ ->
            game
