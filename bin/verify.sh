#!/bin/sh

NETWORK="mumbai"
LeaderboardFacet="0x193c7Ff6ac3Cbb17dA56a1C0feE26b0D4cd34788"
PepeDefenseFacet="0x14080F8572b5Baad056E75626141F12A2B449eB8"
StateViewFacet="0x85374e8f4fB06fB51dbaefac12A46f5965697a93"
PepeUpgrade="0xc7Cd4a7C300c7F55Bd8e9D4792aC968B62DaA27b"

npm run hardhat -- --network $NETWORK verify $LeaderboardFacet
npm run hardhat -- --network $NETWORK verify $PepeDefenseFacet
npm run hardhat -- --network $NETWORK verify $StateViewFacet
npm run hardhat -- --network $NETWORK verify $PepeUpgrade