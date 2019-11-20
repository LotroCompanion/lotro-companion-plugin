function DecodeLinkDataRaw( data )
	-- write("Incoming data: "..data);
	-- Unencode and uncompress the data
	local decodedTable = TurbineUTF8Binary.Decode( data );
	local hex = TurbineUTF8Binary.HexString( data );
	-- write("Incoming data (hex): "..hex);
	local deflatedDataAsString = string.char( unpack( decodedTable ) );
	deflatedDataAsString = string.sub( deflatedDataAsString, - ( string.len( deflatedDataAsString ) - 8 ) );
	local inflatedData = Zlib.Inflate( deflatedDataAsString );
	
	local hexInflated = TurbineUTF8Binary.HexString( inflatedData );
	-- write("Incoming data - inflated (hex): "..hexInflated);

	-- set up the data as a 'stream', sort of
	local ins = ByteStream();
	ins:SetData( inflatedData );
	
-- Retrieve what info we can
	result = {};
	result.rawData = inflatedData;
	return result;
end
