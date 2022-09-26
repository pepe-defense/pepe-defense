#!/bin/sh

NETWORK="mumbai"
LeaderboardFacet="0x0c697Cc43747eb813EB7e3dBb337b47156743d18"
PepeDefenseFacet="0x9Bcb7c6e2F02B0351085436e8167862588C4ef3C"
StateViewFacet="0x14957165d268c41753012758cd31f3F120E402a7"
PepeUpgrade="0xf2c71685Caef37a6922b4aDb898A5152A7621C16"

npx hardhat --network $NETWORK verify $LeaderboardFacet
npx hardhat --network $NETWORK verify $PepeDefenseFacet
npx hardhat --network $NETWORK verify $StateViewFacet
npx hardhat --network $NETWORK verify $PepeUpgrade