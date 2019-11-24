-- Main.lua
-- written by Glumlug, inspired by Habna

import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";
import "Turbine.Gameplay";

import "LotroCompanion.ItemLinkDecode";

AppDir = "LotroCompanion.LotroCompanion";
AppDirD = AppDir..".";

AppClassD = AppDirD.."Class.";
AppCtrD = AppDirD.."Control.";
AppLocaleD = AppDirD.."Locale.";

Version = Plugins["LotroCompanion"]:GetVersion();--> ** LotroCompanion current version **

screenWidth, screenHeight = Turbine.UI.Display.GetSize();
write = Turbine.Shell.WriteLine;

--**v Get player instance v**
Player = Turbine.Gameplay.LocalPlayer.GetInstance();
vaultpack = Player:GetVault();
sspack = Player:GetSharedStorage();
backpack = Player:GetBackpack();
--PlayerAlign = 2;--debug purpose
--bankpack = Player:GetBank();
--PlayerMount = Player:GetMount();
--PlayerPet = Player:GetPet();
--**

MYCHAR = Turbine.Gameplay.LocalPlayer.GetInstance();
MYATTS = MYCHAR:GetAttributes();
MYNAME = MYCHAR:GetName();

_PROFESSIONSINFO = {};
_RECIPES = {};


--**v Detect Game Language v**
-- Legend: 0 = invalid / 2 = English / 268435457 = EnglishGB / 268435459 = Francais / 268435460 = Deutsch / 268435463 = Russian
GLocale = Turbine.Engine.GetLanguage();
if GLocale == 268435459 then GLocale = "fr";
elseif GLocale == 268435460 then GLocale = "de"; 
else GLocale = "en";
end
--**^

LotroCompanionCommand = Turbine.ShellCommand()

function LotroCompanionCommand:Execute( command, arguments )
	if ( arguments == "dump") then
		Dump();
	elseif ( arguments == "start") then
		StartCapture();
	elseif ( arguments == "stop") then
		StopCapture();
	else
		ShowNS = true;
	end

	if ShowNS then write( "LotroCompanion: " .. "Command not supported" ); ShowNS = nil; end -- Command not supported
end

Turbine.Shell.AddCommand('lc', LotroCompanionCommand)
PlayerAtt = Player:GetAttributes();

characterData = {};
craftingData = {};

function Dump()
	-- write( "Dump" );

	characterData = {};

	-- infos
	UpdatePlayersInfos();
	-- money
	characterData["money"] = {};
	local money = PlayerAtt:GetMoney();
	DecryptMoney( money );
	characterData["money"].gold = gold;
	characterData["money"].silver = silver;
	characterData["money"].copper = copper;
	-- Gear
	GetEquipmentInfos();
	-- Stats
	GetStats();
	Turbine.PluginData.Save( Turbine.DataScope.Character, "LotroCompanionCharacter", characterData );

	-- Crafting
	craftingData["Vocation"] = GetMyVocation();
	GetMyProfessions();
	craftingData["Status"] = _PROFESSIONSINFO;
	Turbine.PluginData.Save( Turbine.DataScope.Character, "LotroCompanionCrafting", craftingData );
	Turbine.PluginData.Save( Turbine.DataScope.Character, "LotroCompanionRecipes", _RECIPES );
	-- write( "END Dump" );
end

function DecryptMoney(v)
	gold = math.floor(v / 100000);
	silver = math.floor(v / 100) - gold*1000;
	copper = v - gold*100000 - silver*100;
end

function LoadEquipmentTable()

	Slots = {"Head", "Chest", "Legs", "Gloves", "Boots", "Shoulder", "Back", "Left Bracelet", "Right Bracelet",
		"Necklace", "Left Ring", "Right Ring", "Left Earring", "Right Earring", "Pocket", "Primary Weapon", "Secondary Weapon", "Ranged Weapon",
		"Craft Tool", "Class"};
	--]]
	EquipSlots = {
		Turbine.Gameplay.Equipment.Head, --no 1
		Turbine.Gameplay.Equipment.Chest, --no 2
		Turbine.Gameplay.Equipment.Legs, --no 3
		Turbine.Gameplay.Equipment.Gloves, --no 4
		Turbine.Gameplay.Equipment.Boots, --no 5
		Turbine.Gameplay.Equipment.Shoulder, --no 6
		Turbine.Gameplay.Equipment.Back, --no 7
		Turbine.Gameplay.Equipment.Bracelet1, --no 8
		Turbine.Gameplay.Equipment.Bracelet2, --no 9
		Turbine.Gameplay.Equipment.Necklace, --no 10
		Turbine.Gameplay.Equipment.Ring1, --no 11
		Turbine.Gameplay.Equipment.Ring2, --no 12
		Turbine.Gameplay.Equipment.Earring1, --no 13
		Turbine.Gameplay.Equipment.Earring2, --no 14
		Turbine.Gameplay.Equipment.Pocket, --no 15
		Turbine.Gameplay.Equipment.PrimaryWeapon, --no 16
		Turbine.Gameplay.Equipment.SecondaryWeapon, --no 17
		Turbine.Gameplay.Equipment.RangedWeapon, --no 18
		Turbine.Gameplay.Equipment.CraftTool, --no 19
		Turbine.Gameplay.Equipment.Class, --no 20
	};
end

function GetStats()
	stats = {};
	stats["MORALE"]=Player:GetMorale();
	stats["MAXMORALE"]=Player:GetMaxMorale();
	stats["OCMR"]=PlayerAtt:GetOutOfCombatMoraleRegeneration();
	stats["ICMR"]=PlayerAtt:GetInCombatMoraleRegeneration();


	PlayerRaceIs = Player:GetRace();
	if PlayerClassIs == 214 then
		-- Beorning
		Power = Player:GetClassAttributes():GetWrath();
		MaxPower = 100;
	else 
		Power = Player:GetPower();
		MaxPower = Player:GetMaxPower();
	end;
	stats["POWER"]=Power;
	stats["ICPR"]=PlayerAtt:GetInCombatPowerRegeneration();
	stats["OCPR"]=PlayerAtt:GetOutOfCombatPowerRegeneration();

	PlayerAlign=Player:GetAlignment();
	if PlayerAlign == 1 then
		stats["ARMOR"]=PlayerAtt:GetArmor();
		stats["BASE_ARMOR"]=PlayerAtt:GetBaseArmor();

		-- HEALING --
		stats["OUTGOING_HEALING"]=PlayerAtt:GetOutgoingHealing();
		stats["INCOMING_HEALING"]=PlayerAtt:GetIncomingHealing();
		-- HEALING END --
		
		-- STATISTICS --
		stats["MIGHT"]=PlayerAtt:GetMight();
		stats["BASE_MIGHT"]=PlayerAtt:GetBaseMight();
		stats["AGILITY"]=PlayerAtt:GetAgility();
		stats["BASE_AGILITY"]=PlayerAtt:GetBaseAgility();
		stats["VITALITY"]=PlayerAtt:GetVitality();
		stats["BASE_VITALITY"]=PlayerAtt:GetBaseVitality();
		stats["WILL"]=PlayerAtt:GetWill();
		stats["BASE_WILL"]=PlayerAtt:GetBaseWill();
		stats["FATE"]=PlayerAtt:GetFate();
		stats["BASE_FATE"]=PlayerAtt:GetBaseFate();
		stats["FINESSE"]=PlayerAtt:GetFinesse();

		-- STATISTICS END --
		
		-- MITIGATIONS
		stats["COMMON_MITIGATION"]=PlayerAtt:GetCommonMitigation();
		stats["TACTICAL_MITIGATION"]=PlayerAtt:GetTacticalMitigation();
		stats["PHYSICAL_MITIGATION"]=PlayerAtt:GetPhysicalMitigation();
		stats["FIRE_MITIGATION"]=PlayerAtt:GetFireMitigation();
		stats["LIGHTNING_MITIGATION"]=PlayerAtt:GetLightningMitigation();
		stats["FROST_MITIGATION"]=PlayerAtt:GetFrostMitigation();
		stats["ACID_MITIGATION"]=PlayerAtt:GetAcidMitigation();
		stats["SHADOW_MITIGATION"]=PlayerAtt:GetShadowMitigation();
		-- MITIGATIONS END --
		
		-- OFFENCE --
		stats["MELEE_DAMAGE"]=PlayerAtt:GetMeleeDamage();
		stats["RANGE_DAMAGE"]=PlayerAtt:GetRangeDamage();
		stats["TACTICAL_DAMAGE"]=PlayerAtt:GetTacticalDamage();
		stats["CRITICAL_RATING"]=PlayerAtt:GetBaseCriticalHitChance();
		stats["MELEE_CRIT"]=PlayerAtt:GetMeleeCriticalHitChance();
		stats["TACTICAL_CRIT"]=PlayerAtt:GetTacticalCriticalHitChance();
		stats["RANGED_CRIT"]=PlayerAtt:GetRangeCriticalHitChance();
		-- OFFENCE END --
		
		-- DEFENCE --
		stats["CRITICAL_DEFENCE"]=PlayerAtt:GetBaseCriticalHitAvoidance();
		stats["CRITICAL_DEFENCE_MELEE"]=PlayerAtt:GetMeleeCriticalHitAvoidance();
		stats["CRITICAL_DEFENCE_RANGED"]=PlayerAtt:GetRangeCriticalHitAvoidance();
		stats["CRITICAL_DEFENCE_TACTICAL"]=PlayerAtt:GetTacticalCriticalHitAvoidance();
		stats["MELEE_DEFENCE"]=PlayerAtt:GetMeleeDefence();
		stats["RANGE_DEFENCE"]=PlayerAtt:GetRangeDefence();
		stats["TACTICAL_DEFENCE"]=PlayerAtt:GetTacticalDefence();

		stats["RESISTANCE"]=PlayerAtt:GetBaseResistance();
		stats["POISON_RESIST"]=PlayerAtt:GetPoisonResistance();
		stats["FEAR_RESIST"]=PlayerAtt:GetFearResistance();
		stats["DISEASE_RESIST"]=PlayerAtt:GetDiseaseResistance();
		stats["WOUND_RESISTS"]=PlayerAtt:GetWoundResistance();

		stats["BLOCK"]=PlayerAtt:GetBlock();
		stats["CAN_BLOCK"]=PlayerAtt:CanBlock();
		stats["PARRY"]=PlayerAtt:GetParry();
		stats["CAN_PARRY"]=PlayerAtt:CanParry();
		stats["EVADE"]=PlayerAtt:GetEvade();
		stats["CAN_EVADE"]=PlayerAtt:CanEvade();
		-- DEFENCE END --
	end

	characterData["stats"] = stats;
end

function GetEquipmentInfos()
	LoadEquipmentTable();
	PlayerEquipment = Player:GetEquipment();
	if PlayerEquipment == nil then write("<rgb=#FF3333>No equipment, returning.</rgb>"); return end --Remove when Player Equipment info are available before plugin is loaded

	itemEquip = {};
	itemScore, numItems = 0, 0;
	Wq = 4; -- weight Quality
	Wd = 1; -- weight Durability
	
	for i, v in ipairs( EquipSlots ) do
		local PlayerEquipItem = PlayerEquipment:GetItem( v );
		itemEquip[i] = {};
		-- itemEquip[i] = Turbine.UI.Lotro.ItemControl( PlayerEquipItem );

		-- Item Name, WearState, Quality & Durability
		if PlayerEquipItem ~= nil then
			itemEquip[i].Item = true;
			itemEquip[i].GivenName = PlayerEquipItem:GetName();
			itemEquip[i].Slot = Slots[i];--Debug

			local Quality = PlayerEquipItem:GetQuality();
			itemEquip[i].Quality = Quality;
			-- 0 Undefined ; 1 Legendary ; 2 Rare ; 3 Incomparable ; 4 Uncommon ; 5 Common
			local Durability = PlayerEquipItem:GetDurability();
			itemEquip[i].Durability = Durability;
			-- 0 Undefined ; 1 Substantial ; 2 Brittle ; 3 Normal ; 4 Tough ; 5 Flimsy ; 6 Indestructible ; 7 Weak
			itemEquip[i].WearState = PlayerEquipItem:GetWearState();
			-- 0 Undefined ; 1 Damaged ; 2 Pristine ; 3 Broken ; 4 Worn
			itemEquip[i].BImgID = PlayerEquipItem:GetBackgroundImageID();
			-- itemEquip[i].QImgID = PlayerEquipItem:GetQualityImageID();
			-- itemEquip[i].UImgID = PlayerEquipItem:GetUnderlayImageID();
			-- itemEquip[i].SImgID = PlayerEquipItem:GetShadowImageID();
			itemEquip[i].IImgID = PlayerEquipItem:GetIconImageID();
			itemInfo = PlayerEquipItem:GetItemInfo();
			if itemInfo ~= nil then
				-- itemEquip[i].NameAndQuantity = itemInfo:GetNameWithQuantity();
				itemEquip[i].MaxQuantity = itemInfo:GetMaxQuantity();
				itemEquip[i].Name = itemInfo:GetName();
				-- itemEquip[i].Description = itemInfo:GetDescription();
			end;
		else
			itemEquip[i].Item = false;
		end
	end
	characterData["gear"] = itemEquip;
end

function UpdatePlayersInfos()

	infos = {};

	-- character main attributes
	infos["Name"] = Player:GetName();
	infos["Align"] = Player:GetAlignment(); --1: Free People / 2: Monster Play

	-- infos["raceAttrs"] = Player:GetRaceAttributes();
	-- infos["attrs"] = Player:GetAttributes();
	-- infos["classAttrs"] = Player:GetClassAttributes();
	-- infos["mount"] = Player:GetMount();

	-- Race
	PlayerRaceIs = Player:GetRace();
	  --Free people race
	if PlayerRaceIs == 0 then PlayerRaceIs = ""; -- Undefined
	elseif PlayerRaceIs == 65 then PlayerRaceIs = "Elf";
	elseif PlayerRaceIs == 23 then PlayerRaceIs = "Man";
	elseif PlayerRaceIs == 73 then PlayerRaceIs = "Dwarf";
	elseif PlayerRaceIs == 81 then PlayerRaceIs = "Hobbit";
	elseif PlayerRaceIs == 114 then PlayerRaceIs = "Beorning";
	  --Monster play race
	elseif PlayerRaceIs == 7 then PlayerRaceIs = ""; end
	infos["Race"] = PlayerRaceIs;
	
	-- Class
	PlayerClassIs = Player:GetClass();
	
	--Free People Class
	if PlayerClassIs == 23 then PlayerClassIs = "Guardian";
	elseif PlayerClassIs == 24 then PlayerClassIs = "Captain";
	elseif PlayerClassIs == 31 then
		PlayerClassIs = "Minstrel";
		minstrelAttrs = Player:GetClassAttributes();
		minstrelStanceCode = minstrelAttrs:GetStance();
		if (minstrelStanceCode == Turbine.Gameplay.Attributes.MinstrelStance["WarSpeech"]) then infos["Stance"] = "WarSpeech";
		elseif (minstrelStanceCode == Turbine.Gameplay.Attributes.MinstrelStance["Harmony"]) then infos["Stance"] = "Harmony"; end
	elseif PlayerClassIs == 40 then PlayerClassIs = "Burglar";
	elseif PlayerClassIs == 162 then
		PlayerClassIs = "Hunter";
		hunterAttrs = Player:GetClassAttributes();
		hunterStanceCode = hunterAttrs:GetStance();
		if (hunterStanceCode == Turbine.Gameplay.Attributes.HunterStance["Precision"]) then infos["Stance"] = "Precision";
		elseif (hunterStanceCode == Turbine.Gameplay.Attributes.HunterStance["Strength"]) then infos["Stance"] = "Strength";
		elseif (hunterStanceCode == Turbine.Gameplay.Attributes.HunterStance["Endurance"]) then infos["Stance"] = "Endurance"; end
	elseif PlayerClassIs == 172 then PlayerClassIs = "Champion";
	elseif PlayerClassIs == 185 then PlayerClassIs = "Lore-Master";
	elseif PlayerClassIs == 193 then PlayerClassIs = "Rune-Keeper";
	elseif PlayerClassIs == 194 then PlayerClassIs = "Warden";
	elseif PlayerClassIs == 214 then PlayerClassIs = "Beorning";
	
	--Monster Play Class
	elseif PlayerClassIs == 52 then PlayerClassIs = "Warleader";
	elseif PlayerClassIs == 71 then PlayerClassIs = "Reaver";
	elseif PlayerClassIs == 126 then PlayerClassIs = "Stalker";
	elseif PlayerClassIs == 127 then PlayerClassIs = "Weaver";
	elseif PlayerClassIs == 128 then PlayerClassIs = "Defiler";
	elseif PlayerClassIs == 179 then PlayerClassIs = "Blackarrow";
	end
	infos["Class"] = PlayerClassIs;

	-- Level
	infos["Level"] = Player:GetLevel();

	-- Destiny points
	infos["DestinyPoints"] = PlayerAtt:GetDestinyPoints();
	
	characterData["infos"] = infos;
end
--**^

function GetMyVocation()

	-- This function gets the players vocation (eg Tinker or Historian) and returns the name as a string.
	local MYVOCATIONINFO = MYATTS:GetVocation();

	if MYVOCATIONINFO == nil then return nil end;

	local VOCATION = "";

	for k,v in pairs(Turbine.Gameplay.Vocation) do

		if v == MYVOCATIONINFO then
			VOCATION = k;
			break;
		end

	end

	return VOCATION;
end

function GetMyProfessions()

	-- This function fills the _PROFESSIONSINFO table with all the profession info
	_PROFESSIONSINFO = {};
	_RECIPES = {};

	-- This function gets each of the characters professions.
	for k,v in pairs (Turbine.Gameplay.Profession) do

		local PROFESSIONINFO = MYATTS:GetProfessionInfo(v); -- If character is not of the profession, this returns nil.

		if PROFESSIONINFO ~= nil then

			_PROFESSIONSINFO[k] =
			{
			["ProficiencyExperience"] = PROFESSIONINFO:GetProficiencyExperience(); -- number
			["ProficiencyExperienceTarget"] = PROFESSIONINFO:GetProficiencyExperienceTarget(); -- number e.g. 760 (Eastemnet)
			["ProficiencyTitle"] = PROFESSIONINFO:GetProficiencyTitle(); -- string e.g. <NAME>, Westfold Prospector
			["ProfessionName"] = PROFESSIONINFO:GetName(); -- string e.g. Prospector
			["MasteryLevel"] = PROFESSIONINFO:GetMasteryLevel(); -- number e.g. 7 (Westfold). The current level you're at, not where you are heading
			["ProficiencyLevel"] = PROFESSIONINFO:GetProficiencyLevel(); -- number e.g. 7 (Westfold)
			["MasteryTitle"] = PROFESSIONINFO:GetMasteryTitle(); -- string e.g. <Name>. Westfold Master Prospector
			["MasteryExperienceTarget"] = PROFESSIONINFO:GetMasteryExperienceTarget(); -- number e.g. 1520 (Eastemnet)
			["MasteryExperience"] = PROFESSIONINFO:GetMasteryExperience(); -- number
			};
			GetMyRecipes(k);
		end
	end
end

-- This function gets the known recipes of the given profession
function GetMyRecipes(PROFESSION)

	if PROFESSION == nil then return end;

	_RECIPES[PROFESSION] = nil;

	local _TEMPRECIPETABLE = {};

	-- Check PROFESSIONS is valid and a known profession
	local PROFESSIONINFO = MYATTS:GetProfessionInfo(Turbine.Gameplay.Profession[PROFESSION]);

	if PROFESSIONINFO ~= nil then

		-- Get recipes.
		if PROFESSIONINFO.GetRecipeCount == nil then return end;
		local MAXRECIPES = PROFESSIONINFO:GetRecipeCount();	-- Number e.g 35 (all recipes across all tiers)

		--Debug(PROFESSION .. " = " .. MAXRECIPES);


		for i=1, MAXRECIPES do

			local TEMPRECIPE = PROFESSIONINFO:GetRecipe(i);
			local itemInfo = TEMPRECIPE:GetResultItemInfo();

			_TEMPRECIPETABLE[i] =
			{
			["Name"] = TEMPRECIPE:GetName(); -- string e.g. Polished Red Agate
			["IsKnown"] = true;
			["CategoryName"] = TEMPRECIPE:GetCategoryName(); -- string e.g. Gemstones
			["OptionalIngredientCount"] = TEMPRECIPE:GetOptionalIngredientCount(); -- number e.g. 1
			["Tier"] = TEMPRECIPE:GetTier(); -- number e.g. 8 (8 = Eastemnet from Turbine.Gameplay.CraftTier)
			["ExperienceReward"] = TEMPRECIPE:GetExperienceReward(); -- number e.g. 8 (xp)
			["Cooldown"] = TEMPRECIPE:GetCooldown(); -- number e.g. -1 (I guess for no cd.) Time is given in seconds e.g. 237600 seconds = 2 days 18 hours
			-- ["Profession"] = TEMPRECIPE:GetProfession(); -- number e.g. 4 (4 = Jeweller from Turbine.Gameplay.Profession)
			["IngredientCount"] = TEMPRECIPE:GetIngredientCount(); -- number e.g 1
			["HasCriticalResultItem"] = TEMPRECIPE:HasCriticalResultItem(); -- boolean
			["Category"] = TEMPRECIPE:GetCategory(); -- number e.g. 12
			["IsSingleUse"] = TEMPRECIPE:IsSingleUse(); -- boolean
			["BaseCriticalSuccessChance"] = TEMPRECIPE:GetBaseCriticalSuccessChance(); -- number in decimal format e.g. 0.050000000745058 == 5%
			["CriticalSuccessItemQuantity"] = TEMPRECIPE:GetCriticalResultItemQuantity(); -- number e.g. 3
			["ResultItemQuantity"] = TEMPRECIPE:GetResultItemQuantity(); -- number e.g. 1

			["IngredientPack"] = TEMPRECIPE:GetIngredientPack(); -- returns nil if there is none.
			["ResultItemName"] = itemInfo:GetName(); -- string
			["ResultItemIconID"] = itemInfo:GetIconImageID();
			["ResultItemBackgroundIconID"] = itemInfo:GetBackgroundImageID();

			["Ingredients"] = {}; -- Blank to be filled later.
			["OptionalIngredient"] = {}; -- Blank to be filled later.

			};


			-- If the item has a critical result item then get the info for it.
			if _TEMPRECIPETABLE[i].HasCriticalResultItem == true then
				local critResultItemInfo = TEMPRECIPE:GetCriticalResultItemInfo();
				_TEMPRECIPETABLE[i].CriticalResultItemName = critResultItemInfo:GetName(); -- string
				_TEMPRECIPETABLE[i]["CriticalResultItemIconId"] = critResultItemInfo:GetIconImageID(); -- string
				_TEMPRECIPETABLE[i]["CriticalResultItemBackgroundIconId"] = critResultItemInfo:GetBackgroundImageID(); -- string
			end


			-- Ingredients table
			local _TEMPINGREDIENTTABLE = _TEMPRECIPETABLE[i].Ingredients;

			for a=1, _TEMPRECIPETABLE[i].IngredientCount do

				local TEMPINGREDIENT = TEMPRECIPE:GetIngredient(a); -- Returns RECIPE INGREDIENT

				local itemInfo = TEMPINGREDIENT:GetItemInfo();
				_TEMPINGREDIENTTABLE[a] =
				{
					["Name"] = itemInfo:GetName(); -- String e.g. Polished Green Garnet
					-- ["CriticalChanceBonus"] = TEMPINGREDIENT:GetCriticalChanceBonus(); -- number e.g. 0.44999998807907 (45%)
					["RequiredQuantity"] = TEMPINGREDIENT:GetRequiredQuantity(); -- number e.g. 3
					["IconID"] = itemInfo:GetIconImageID();
					["BackgroundIconID"] = itemInfo:GetBackgroundImageID();
				};
			end


			-- Optional ingredients table
			local _TEMPOPTINGREDIENTTABLE = _TEMPRECIPETABLE[i].OptionalIngredient;

			for a=1, _TEMPRECIPETABLE[i].OptionalIngredientCount do

				local TEMPINGREDIENT = TEMPRECIPE:GetOptionalIngredient(a); -- Returns RECIPE INGREDIENT
				local itemInfo = TEMPINGREDIENT:GetItemInfo();

				_TEMPOPTINGREDIENTTABLE[a] =
				{
					["Name"] = itemInfo:GetName(); -- String e.g. Polished Green Garnet
					["CriticalChanceBonus"] = TEMPINGREDIENT:GetCriticalChanceBonus(); -- number e.g. 0.44999998807907 (45%)
					["RequiredQuantity"] = TEMPINGREDIENT:GetRequiredQuantity(); -- number e.g. 3
					["IconID"] = itemInfo:GetIconImageID();
					["BackgroundIconID"] = itemInfo:GetBackgroundImageID();
				};
			end

		end

		_RECIPES[PROFESSION]  = deepcopy(_TEMPRECIPETABLE);

	end

end

--This function returns a deep copy of a given table ---------------
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end


Turbine.Plugin.Load = function( self, sender, args )
	write("Loaded plugin LotroCompanion");
	-- Dump();
end

Turbine.Plugin.Unload = function( self, sender, args )
	write("Unloaded plugin LotroCompanion");
	-- Dump();
end

dataItems = Turbine.PluginData.Load(Turbine.DataScope.Character,"LotroCompanionItems");
if dataItems == nil then
	dataItems = {};
	dataItems.counter = 1;
end

local handleChatItem = function(itemData)
	local decodedItem = LotroCompanion.ItemLinkDecode.DecodeLinkDataRaw( itemData );
	if decodedItem ~= nil then
		newItem = {};
		newItem.item = decodedItem;
		newItem.timestamp = Turbine.Engine:GetLocalTime();
		dataItems[dataItems.counter] = newItem;
		dataItems.counter=dataItems.counter+1;
		if dataItems.counter == 100 then
			dataItems.counter = 1;
		end
		write("Got an item");
		-- write("Saving data");
		Turbine.PluginData.Save( Turbine.DataScope.Character, "LotroCompanionItems", dataItems );
	end
end

chatHookState = 'Disabled';

function StartCapture()
	chatHookState = 'Enabled';
	write("LotroCompanion: item capture is enabled");
end

function StopCapture()
	chatHookState = 'Disabled';
	write("LotroCompanion: item capture is disabled");
end

local chatHook = function (sender, args)
	if (chatHookState == 'Disabled') then
		return;
	end
	-- write("Message: "..args.Message);
	local pre, data, post = string.match( args.Message, "<Examine(.*)>(%b[])<\\Examine(.*)>" ); 
	if pre ~= nil then
		-- write("pre="..pre);
		-- for normal non parametered items (e.g. recipe elements with count=1), gives
		-- :IIDDID:0x0000000000000000:0x70022192
		-- where last hexa element is the item ID
		local value1,id = string.match( pre, ":IIDDID:0x(.*):0x(.*)" ); 
		if id ~= nil then
			write("ID(hex)="..id);
		end
	end
	if data ~= nil then
		-- write("data="..data);
	end
	if post ~= nil then
		-- write("post="..post);
	end
	local LIData, name = string.match( args.Message, "<ExamineIA:IAInfo:(.*)>(%b[])<\\ExamineIA>" ); 
	if LIData ~= nil then
		-- write("Got legendary item!");
		handleChatItem(LIData);
		return;
	end
	local itemData, name = string.match( args.Message, "<ExamineItemInstance:ItemInfo:(.*)>(%b[])<\\ExamineItemInstance>" );
	if itemData ~= nil then
		-- write("Got regular item!");
		handleChatItem(itemData);
	end
end

-- install the chat hook
if type(Turbine.Chat.Received) == "table" then
	table.insert( Turbine.Chat.Received, chatHook );
	write("LotroCompanion: added chat hook");
else
	local existingHook = Turbine.Chat.Received;
	Turbine.Chat.Received = { chatHook, existingHook };
	write("LotroCompanion: inserted chat hook");
end
