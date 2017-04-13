/*
	Mapping API - kzpro_
	
	Detects the kzpro_ map tag.
*/

void KZProOnMapStart()
{
	char map[64], mapPieces[5][64], mapPrefix[1][64];
	
	GetCurrentMap(map, sizeof(map));
	int lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	ExplodeString(mapPieces[lastPiece - 1], "_", mapPrefix, sizeof(mapPrefix), sizeof(mapPrefix[]));
	gB_CurrentMapIsKZPro = StrEqual(mapPrefix[0], "kzpro", false);
} 