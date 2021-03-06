
global function InitPlayVideoMenu
global function PlayVideoMenu
global function SetVideoCompleteFunc

const string INTRO_VIDEO = "intro"

struct
{
	var menu
	string video
	string milesAudio
	bool skippable = true
	var ruiSkipLabel
	bool holdInProgress = false
	void functionref() videoCompleteFunc
} file

void function InitPlayVideoMenu()
{
	RegisterSignal( "PlayVideoMenuClosed" )
	RegisterSignal( "SkipVideoHoldReleased" )

	var menu = GetMenu( "PlayVideoMenu" )
	file.menu = menu

	SetDialog( menu, true )
	SetGamepadCursorEnabled( menu, false )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnPlayVideoMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnPlayVideoMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnPlayVideoMenu_NavigateBack )

	var vguiSkipLabel = Hud_GetChild( menu, "SkipLabel" )
	Hud_SetAboveBlur( vguiSkipLabel, true )
	file.ruiSkipLabel = Hud_GetRui( vguiSkipLabel )
}

void function PlayVideoMenu( string video, string milesAudio = "", bool skippable = true, void functionref() func = null )
{
	Assert( video != "" )

	file.video = video
	file.milesAudio = milesAudio
	file.skippable = skippable
	file.videoCompleteFunc = func
	AdvanceMenu( file.menu )
}

void function SetVideoCompleteFunc( void functionref() func )
{
	file.videoCompleteFunc = func
}

void function OnPlayVideoMenu_Open()
{
	EndSignal( uiGlobal.signalDummy, "PlayVideoMenuClosed" )

	Assert( file.video != "" )

	bool forceUseCaptioning = false
	if ( GetLanguage() != "english" && file.video != INTRO_VIDEO )
		forceUseCaptioning = true

	DisableBackgroundMovie()
	SetMouseCursorVisible( false )
	StopVideos( eVideoPanelContext.UI )
	StopUIMusic()
	PlayVideoFullScreen( file.video, file.milesAudio, forceUseCaptioning )
	uiGlobal.playingVideo = true

	if ( file.skippable )
	{
		thread WaitForSkipInput()

		if ( file.video == INTRO_VIDEO && IsIntroViewed() )
			ShowAndFadeSkipLabel()
	}

	WaitSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	if ( GetActiveMenu() == file.menu )
		thread CloseActiveMenu()
}

void function OnPlayVideoMenu_Close()
{
	Signal( uiGlobal.signalDummy, "PlayVideoMenuClosed" )

	StopVideos( eVideoPanelContext.UI )
	if ( file.milesAudio != "" )
		StopUISoundByName( file.milesAudio )
	file.video = ""
	file.milesAudio = ""
	EnableBackgroundMovie()
	SetMouseCursorVisible( true )
	uiGlobal.playingVideo = false
	PlayContextualMenuMusic()

	if ( file.videoCompleteFunc != null )
		thread file.videoCompleteFunc()
}

void function OnPlayVideoMenu_NavigateBack()
{
	//
}

void function WaitForSkipInput()
{
	EndSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	array<int> inputs

	//
	inputs.append( BUTTON_A )
	inputs.append( BUTTON_B )
	inputs.append( BUTTON_X )
	inputs.append( BUTTON_Y )
	inputs.append( BUTTON_SHOULDER_LEFT )
	inputs.append( BUTTON_SHOULDER_RIGHT )
	inputs.append( BUTTON_TRIGGER_LEFT )
	inputs.append( BUTTON_TRIGGER_RIGHT )
	inputs.append( BUTTON_BACK )
	inputs.append( BUTTON_START )

	//
	inputs.append( KEY_SPACE )
	inputs.append( KEY_ESCAPE )
	inputs.append( KEY_ENTER )
	inputs.append( KEY_PAD_ENTER )

	WaitFrame() //
	foreach ( input in inputs )
	{
		if ( input == BUTTON_A || input == KEY_SPACE )
		{
			RegisterButtonPressedCallback( input, ThreadSkipButton_Press )
			RegisterButtonReleasedCallback( input, SkipButton_Release )
		}
		else
		{
			RegisterButtonPressedCallback( input, NotifyButton_Press )
		}
	}

	OnThreadEnd(
		function() : ( inputs )
		{
			foreach ( input in inputs )
			{
				if ( input == BUTTON_A || input == KEY_SPACE )
				{
					DeregisterButtonPressedCallback( input, ThreadSkipButton_Press )
					DeregisterButtonReleasedCallback( input, SkipButton_Release )
				}
				else
				{
					DeregisterButtonPressedCallback( input, NotifyButton_Press )
				}
			}
		}
	)

	WaitSignal( uiGlobal.signalDummy, "PlayVideoEnded" )
}

void function ThreadSkipButton_Press( var button )
{
	thread SkipButton_Press()
}

void function NotifyButton_Press( var button )
{
	ShowAndFadeSkipLabel()
}

void function SkipButton_Press()
{
	if ( file.holdInProgress )
		return

	file.holdInProgress = true

	float holdStartTime = Time()
	table hold //
	hold.completed <- false

	EndSignal( uiGlobal.signalDummy, "SkipVideoHoldReleased" )
	EndSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	OnThreadEnd(
		function() : ( hold )
		{
			if ( hold.completed )
				Signal( uiGlobal.signalDummy, "PlayVideoEnded" )

			file.holdInProgress = false
		}
	)

	ShowAndFadeSkipLabel()

	float holdDuration = 0
	while ( holdDuration < 1.5 )
	{
		WaitFrame()
		holdDuration = Time() - holdStartTime
	}

	hold.completed = true
}

void function SkipButton_Release( var button )
{
	Signal( uiGlobal.signalDummy, "SkipVideoHoldReleased" )
}

void function ShowAndFadeSkipLabel()
{
	RuiSetGameTime( file.ruiSkipLabel, "initTime", Time() )
	RuiSetGameTime( file.ruiSkipLabel, "startTime", Time() )
}
