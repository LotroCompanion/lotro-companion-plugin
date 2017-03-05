-- Main.lua
-- written by Glumlug, inspired by Habna

import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";
import "Turbine.Gameplay";

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
	else
		ShowNS = true;
	end

	if ShowNS then write( "LotroCompanion: " .. "Command not supported" ); ShowNS = nil; end -- Command not supported
end

Turbine.Shell.AddCommand('LotroCompanion', LotroCompanionCommand)
PlayerAtt = Player:GetAttributes();

characterData = {};
characterData["money"] = {};

function Dump()
	write( "Dump" );

	-- infos
	UpdatePlayersInfos();
	-- money
	local money = PlayerAtt:GetMoney();
	DecryptMoney( money );
	characterData["money"].gold = gold;
	characterData["money"].silver = silver;
	characterData["money"].copper = copper;
	-- Gear
	GetEquipmentInfos();
	-- Stats
	GetStats();
	Turbine.PluginData.Save( Turbine.DataScope.Server, "LotroCompanionData", characterData );
	write( "END Dump" );
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
		itemEquip[i] = Turbine.UI.Lotro.ItemControl( PlayerEquipItem );
	
		-- Item Name, WearState, Quality & Durability
		if PlayerEquipItem ~= nil then
			itemEquip[i].Item = true;
			itemEquip[i].Name = PlayerEquipItem:GetName();
			itemEquip[i].Slot = Slots[i];--Debug

			local Quality = PlayerEquipItem:GetQuality();
			
			local Durability = PlayerEquipItem:GetDurability();

			itemEquip[i].WearState = PlayerEquipItem:GetWearState();
					
			itemEquip[i].BImgID = PlayerEquipItem:GetBackgroundImageID();
			itemEquip[i].QImgID = PlayerEquipItem:GetQualityImageID();
			itemEquip[i].UImgID = PlayerEquipItem:GetUnderlayImageID();
			itemEquip[i].SImgID = PlayerEquipItem:GetShadowImageID();
			itemEquip[i].IImgID = PlayerEquipItem:GetIconImageID();
			
		else
			itemEquip[i].Item = false;
			itemEquip[i].Name = "zEmpty";
			--itemEquip[i].Quality = 0;
			--itemEquip[i].Durability = 0;
			itemEquip[i].Score = 0;
			itemEquip[i].WearState = 0;
			itemEquip[i].WearStatePts = 0;
			
			if _G.Debug then
				write( "<rgb=#FF0000>"..i.."</rgb>: <rgb=#6969FF>"..Slots[i]..":</rgb> <rgb=#FF3333>NO ITEM</rgb>" );
			end
		end
	end
	characterData["gear"] = itemEquip;
end

function UpdatePlayersInfos()

	infos = {};

	-- character main attributes
	infos["Name"] = Player:GetName();
	infos["Align"] = Player:GetAlignment(); --1: Free People / 2: Monster Play

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
	elseif PlayerClassIs == 31 then PlayerClassIs = "Minstrel";
	elseif PlayerClassIs == 40 then PlayerClassIs = "Burglar";
	elseif PlayerClassIs == 162 then PlayerClassIs = "Hunter";
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


Turbine.Plugin.Load = function( self, sender, args )
	write("Loaded plugin LotroCompanion");
end

Turbine.Plugin.Unload = function( self, sender, args )
	write("Unloading LotroCompanion");
end
