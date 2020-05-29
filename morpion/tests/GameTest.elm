module GameTest exposing (..)

import Array
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Game exposing (..)
import Grid exposing (..)
import Random.List exposing (shuffle)
import Shrink exposing (noShrink)
import Test exposing (Test, describe, fuzz, test)


selectCells : List CellPosition -> Game
selectCells =
    List.foldl selectCell (Running CrossPlayer createGrid)


runGame : List ( Int, Int ) -> Game
runGame =
    List.map (\( x, y ) -> { x = x, y = y }) >> selectCells


testWinningPosition : List ( Int, Int ) -> Expectation
testWinningPosition positions =
    let
        game =
            runGame positions
    in
    Expect.equal (Won CrossPlayer (getGrid game)) game


fuzzPositions : Fuzzer (List CellPosition)
fuzzPositions =
    Fuzz.custom (shuffle allPossiblePositions) noShrink


suite : Test
suite =
    describe "Morpion game"
        [ describe "Game"
            [ test "should switch player" <|
                \_ ->
                    let
                        game =
                            Running CrossPlayer createGrid
                                |> selectCell { x = 0, y = 1 }

                        player =
                            getPlayer game
                    in
                    Expect.equal CirclePlayer player
            , test "Should not update Game state if player tries to click on a non empty cell" <|
                \_ ->
                    let
                        initGame =
                            Running CrossPlayer createGrid

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
                    Expect.equal (Draw (getGrid game)) game
            , fuzz fuzzPositions "Should end with draw or win after clicking on all possible cells" <|
                \positions ->
                    let
                        isNotRunning =
                            \game ->
                                case game of
                                    Running _ _ ->
                                        False

                                    _ ->
                                        True
                    in
                    Expect.equal True (selectCells positions |> isNotRunning)
            ]
        ]
