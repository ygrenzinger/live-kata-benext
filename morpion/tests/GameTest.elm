module GameTest exposing (..)

import Array
import Expect exposing (Expectation)
import Fuzz exposing (intRange)
import Game exposing (Cell, CellState(..), Game(..), Player(..), createGrid, getGrid, getPlayer, selectCell, updateGrid)
import Test exposing (Test, describe, fuzz2, test)



-- Composition of function


runGame : List ( Int, Int ) -> Game
runGame =
    List.map (\( x, y ) -> { x = x, y = y }) >> List.foldl selectCell (Running FirstPlayer createGrid)


testWinningPosition : List ( Int, Int ) -> Expectation
testWinningPosition positions =
    let
        game =
            runGame positions
    in
    Expect.equal (Won FirstPlayer (getGrid game)) game


suite : Test
suite =
    describe "Morpion game"
        [ describe "Grid"
            [ fuzz2 (intRange 0 2) (intRange 0 2) "should update grid with cross because first player" <|
                \x y ->
                    let
                        emptyGrid =
                            createGrid

                        player =
                            FirstPlayer

                        updatedGrid =
                            updateGrid player { x = x, y = y } emptyGrid

                        updatedCell =
                            Array.get y updatedGrid
                                |> Maybe.andThen (\row -> Array.get x row)
                    in
                    Expect.equal (Just (Cell { x = x, y = y } Cross)) updatedCell
            , test "should with circle because second player" <|
                \_ ->
                    let
                        emptyGrid =
                            createGrid

                        player =
                            SecondPlayer

                        updatedGrid =
                            updateGrid player { x = 1, y = 0 } emptyGrid

                        updatedCell =
                            Array.get 0 updatedGrid
                                |> Maybe.andThen (\row -> Array.get 1 row)
                    in
                    Expect.equal (Just (Cell { x = 1, y = 0 } Circle)) updatedCell
            , test "should switch player" <|
                \_ ->
                    let
                        game =
                            Running FirstPlayer createGrid
                                |> selectCell { x = 0, y = 1 }

                        player =
                            getPlayer game
                    in
                    Expect.equal SecondPlayer player
            , test "Should not update Game state if player tries to click on a non empty cell" <|
                \_ ->
                    let
                        initGame =
                            Running FirstPlayer createGrid

                        firstPlayerTurn =
                            selectCell { x = 0, y = 1 } initGame

                        noChange =
                            selectCell { x = 0, y = 1 } firstPlayerTurn
                    in
                    Expect.equal firstPlayerTurn noChange
            , test "should stop the game when first player win when he filled a column" <|
                \_ ->
                    testWinningPosition
                        [ ( 0, 0 )
                        , ( 1, 0 )
                        , ( 0, 1 )
                        , ( 1, 1 )
                        , ( 0, 2 )
                        ]
            , test "should stop the game when first player win when he filled a row" <|
                \_ ->
                    testWinningPosition
                        [ ( 0, 0 )
                        , ( 0, 1 )
                        , ( 1, 0 )
                        , ( 1, 1 )
                        , ( 2, 0 )
                        ]
            , test "should stop the game when first player win when he filled a left to right diagonal" <|
                \_ ->
                    testWinningPosition
                        [ ( 0, 0 )
                        , ( 0, 1 )
                        , ( 1, 1 )
                        , ( 0, 2 )
                        , ( 2, 2 )
                        ]
            , test "should stop the game when first player win when he filled a right to left diagonal" <|
                \_ ->
                    testWinningPosition
                        [ ( 2, 0 )
                        , ( 0, 1 )
                        , ( 1, 1 )
                        , ( 1, 0 )
                        , ( 0, 2 )
                        ]
            , test "should stop the game when there is a draw" <|
                \_ ->
                    let
                        game =
                            runGame
                                [ ( 0, 0 )
                                , ( 1, 1 )
                                , ( 1, 0 )
                                , ( 2, 0 )
                                , ( 0, 2 )
                                , ( 0, 1 )
                                , ( 2, 1 )
                                , ( 1, 2 )
                                , ( 2, 2 )
                                ]
                    in
                    Expect.equal (Draw FirstPlayer (getGrid game)) game
            ]
        ]
