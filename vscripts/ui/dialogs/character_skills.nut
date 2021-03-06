global function InitCharacterSkillsDialog
global function OpenCharacterSkillsDialog

struct
{
	var         menu
	var         contentRui
	ItemFlavor& character
} file

void function InitCharacterSkillsDialog()
{
	var menu = GetMenu( "CharacterSkillsDialog" )
	file.menu = menu

	SetDialog( menu, true )
	SetGamepadCursorEnabled( menu, false )

	file.contentRui = Hud_GetRui( Hud_GetChild( file.menu, "ContentRui" ) )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, CharacterSkillsDialog_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, CharacterSkillsDialog_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, CharacterSkillsDialog_OnNavigateBack )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#OK" )

	HudElem_SetChildRuiArg( menu, "BG", "basicImage", $"rui/menu/character_skills/background", eRuiArgType.IMAGE )
}


void function OpenCharacterSkillsDialog( ItemFlavor character )
{
	file.character = character
	AdvanceMenu( file.menu )
}


void function CharacterSkillsDialog_OnOpen()
{
	//
	EmitUISound( "UI_Menu_Legend_Details" )

	if ( LoadoutSlot_IsReady( ToEHI( GetUIPlayer() ), Loadout_CharacterClass() ) )
	{
		CharacterHudUltimateColorData colorData = CharacterClass_GetHudUltimateColorData( file.character )
		RuiSetColorAlpha( file.contentRui, "ultimateColor", SrgbToLinear( colorData.ultimateColor ), 1 )
		RuiSetColorAlpha( file.contentRui, "ultimateColorHighlight", SrgbToLinear( colorData.ultimateColorHighlight ), 1 )
	}

	RuiSetImage( file.contentRui, "passiveIcon", ItemFlavor_GetIcon( CharacterClass_GetPassiveAbility( file.character ) ) )
	RuiSetString( file.contentRui, "passiveName", Localize( ItemFlavor_GetLongName( CharacterClass_GetPassiveAbility( file.character ) ) ) )
	RuiSetString( file.contentRui, "passiveDesc", Localize( ItemFlavor_GetLongDescription( CharacterClass_GetPassiveAbility( file.character ) ) ) )
	RuiSetString( file.contentRui, "passiveType", Localize( "#PASSIVE" ) )

	RuiSetImage( file.contentRui, "tacticalIcon", ItemFlavor_GetIcon( CharacterClass_GetTacticalAbility( file.character ) ) )
	RuiSetString( file.contentRui, "tacticalName", Localize( ItemFlavor_GetLongName( CharacterClass_GetTacticalAbility( file.character ) ) ) )
	RuiSetString( file.contentRui, "tacticalDesc", Localize( ItemFlavor_GetLongDescription( CharacterClass_GetTacticalAbility( file.character ) ) ) )
	RuiSetString( file.contentRui, "tacticalType", Localize( "#TACTICAL" ) )

	RuiSetImage( file.contentRui, "ultimateIcon", ItemFlavor_GetIcon( CharacterClass_GetUltimateAbility( file.character ) ) )
	RuiSetString( file.contentRui, "ultimateName", Localize( ItemFlavor_GetLongName( CharacterClass_GetUltimateAbility( file.character ) ) ) )
	RuiSetString( file.contentRui, "ultimateDesc", Localize( ItemFlavor_GetLongDescription( CharacterClass_GetUltimateAbility( file.character ) ) ) )
	RuiSetString( file.contentRui, "ultimateType", Localize( "#ULTIMATE" ) )

	RuiSetGameTime( file.contentRui, "initTime", Time() )
}


void function CharacterSkillsDialog_OnClose()
{
}


void function CharacterSkillsDialog_OnNavigateBack()
{
	CloseActiveMenu()
}
