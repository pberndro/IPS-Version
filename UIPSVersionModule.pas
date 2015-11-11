unit UIPSVersionModule;

interface

uses Windows, Messages, SysUtils, ActiveX, Classes, Forms, StdCtrls,
     Dialogs, StrUtils, ExtCtrls, ScktComp, WinSock,
     UIPSTypes, UIPSModuleTypes, UIPSDataTypes,
     IPSLicense, IPSLive;

type
 IIPSVersionModule = interface(IInvokable)
  ['{25DB46CB-8575-426A-9EEA-64AC7F7D1AA7}']

  //Actions for PHP Scrips
  procedure RefreshData; stdcall;
  //procedure TestFunctionParam(Test: Boolean); stdcall;

 end;

 TIPSVersionModule = class(TIPSModuleObject,
                        IIPSModule,
                        IIPSVersionModule,
                        IIPSReceiveString)
  private
   //--- Basic Structures
   //--- Custom Objects
   //--- Private Procedures/Functions
   procedure TimerFire;
   procedure fillIPSVars;
   procedure Log(LogText : string);


  protected
   { Overrides }
   procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
   procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer); override;

  public
   constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   destructor  Destroy; override;
   // --- TIPSMessageObject override
   procedure MessageSink(var Msg: TIPSMessage); override;

   //--- IIPSModule implementation
   { Configuration Form }
   function GetConfigurationForm(): String; override; stdcall;
   procedure LoadSettings(); override;
   procedure SaveSettings(); override;
   procedure ResetChanges(); override;
   procedure ApplyChanges(); override;

   //--- IIPSTestModule implementation
   procedure RefreshData; stdcall;
   //procedure TestFunction; stdcall;
   //procedure TestFunctionParam(Test: Boolean); stdcall;

   { Data Points }
   procedure ReceiveText(Text: String); stdcall;

   { Class Functions }
   class function GetModuleID(): TStrGUID; override;
   class function GetModuleType(): TIPSModuleType; override;
   class function GetVendor(): String; override;
   class function GetModuleName(): String; override;
   //class function GetParentRequirements(): TStrGUIDs; override;
   //class function GetImplemented(): TStrGUIDs; override;

 end;

implementation

const
  //IPS Var Names
  IPS_VAR_VersionUpdateIdLocal    = 'Version_UpdateIdLocal';
  IPS_VAR_VersionUpdateIdLive     = 'Version_UpdateIdLive';
  IPS_VAR_VersionUpdateDateLocal  = 'Version_UpdateDateLocal';
  IPS_VAR_VersionUpdateDateLive   = 'Version_UpdateDateLive';
  IPS_VAR_Subscription            = 'Version_Subscription';


//------------------------------------------------------------------------------
class function TIPSVersionModule.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSVersionModule); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSVersionModule.GetModuleType(): TIPSModuleType;
begin
 Result := mtDevice;
end;

//------------------------------------------------------------------------------
//Vendor Name
class function TIPSVersionModule.GetVendor(): String;
begin
 Result := 'IPS Version';
end;

//Device Name
//------------------------------------------------------------------------------
class function TIPSVersionModule.GetModuleName(): String;
begin
 Result := 'IPS Version';
end;


//------------------------------------------------------------------------------
//class function TIPSVersionModule.GetParentRequirements(): TStrGUIDs;
//begin

 //SetLength(Result, 1);
 //Result[0] := GUIDToString(IIPSSendString);

//end;

//------------------------------------------------------------------------------
//class function TIPSVersionModule.GetImplemented(): TStrGUIDs;
//begin
 //SetLength(Result, 1);
 //Result[0] := GUIDToString(IIPSReceiveString);
//end;


//------------------------------------------------------------------------------
constructor TIPSVersionModule.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
begin

 inherited;

 //Register Variables
 RegisterVariable(IPS_VAR_VersionUpdateIdLocal, 'UpdateIdLocal', vtInteger, '',nil ,1);
 RegisterVariable(IPS_VAR_VersionUpdateIdLive, 'UpdateIdLive', vtInteger, '',nil, 2);
 RegisterVariable(IPS_VAR_VersionUpdateDateLocal, 'UpdateDateLocal', vtString, '', nil, 3);
 RegisterVariable(IPS_VAR_VersionUpdateDateLive, 'UpdateDateLive', vtString, '', nil, 4);
 RegisterVariable(IPS_VAR_Subscription, 'Subscription', vtString, '', nil, 5);


 //Register Property
 RegisterProperty('RefreshInterval', 180); //180 minutes - 3 hours

 //Register Timer
 RegisterTimer('VersionCheckTimer', 10800, TimerFire); //every 180 minutes = 10800 seconds

 //Check Parent instance and force to create this instance
 //RequireParent(IIPSClientSocket, True);

 //ToDo: Write to Logfile
 //LogMessage(KL_DEBUG,'Netatmo instance installed successfully');
 Self.Log('Create() end');
 
end;

//------------------------------------------------------------------------------
destructor  TIPSVersionModule.Destroy;
begin

 inherited;

end;


//------------------------------------------------------------------------------
procedure TIPSVersionModule.ProcessKernelRunlevelChange(Runlevel: Integer);
begin

 inherited;

 case Runlevel of
  KR_READY:
   if HasActiveParent() then
    ; //Send an initialize sequence to your device. Your I/O is active here, if not explicitly inactive or in an error state
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin

 //define any more properties as you want. see docs for IPS_SetProperty
 //comaparising might be >=, =, <=
 //multiple, same properties will be threatet as an OR statement

 //either of these port is allowed. last will be configured, if current port do not match
 if InstanceID = fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) then
  if Status = IS_ACTIVE then
   ForceParentConfiguration(IIPSClientSocket,
    [
      'Port', '=', '4567',
      'Port', '=', '1234'
    ]);

 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.MessageSink(var Msg: TIPSMessage);
begin

 inherited;

 //react on special message here

end;

//------------------------------------------------------------------------------
function TIPSVersionModule.GetConfigurationForm(): String;
begin

 Result := '{'
	+'"elements":'
	+'['
  //+ ' { "name": "Username", "type": "ValidationTextBox", caption: "Benutzername" },'
  //+ ' { "name": "Password", "type": "PasswordTextBox", caption: "Passwort" },'
	+'	{ "name": "RefreshInterval", "type": "NumberSpinner", "caption": "Abfrageintervall (min)" }'
	+']'
  +'}';

end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.LoadSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.ResetChanges();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.ApplyChanges();
var
  interval : Integer;
begin
 //this is explicitly needed at the beginning, otherwise GetPropety will not reflect new changes
 inherited;

 interval := GetProperty('RefreshInterval') * 60; //timer needs seconds user sets minutes
 SetTimerInterval('VersionCheckTimer', interval);

 //fill the ips var's with fresh data
 fillIPSVars();
end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.RefreshData; stdcall;
begin
  fillIPSVars();
end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.TimerFire;
begin
  fillIPSVars();
end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.fillIPSVars;
var
  username, license: String;
  limitVars : Integer;
  ret : Boolean;
  varId : Word;

  updateDateLive : String;
  updateIdLive : Integer;
  updateDateLocal : String;
  updateIdLocal : Integer;
  subscription : String;
begin
  username := fKernel.LicensePool.GetLicensee();
  limitVars := fKernel.LicensePool.GetLimitVariables();
  license   := IPSLicense.GetLicense();

  ret := IPSLive.Login(username, license, limitVars);
  if ret = True then
    begin
      //live update version
      updateDateLive := IPSLive.GetVersionDate();
      updateIdLive := IPSLive.GetVersion();

      //installed version
      updateDateLocal := IPSLicense.GetLastUpdate();
      updateIdLocal := IPSLicense.GetLastUpdateID();

      //end of the subscription
      subscription := IPSLive.GetSubscriptionEnd();

      //-----------------------------------------------------------------//
      //write values in to the ips vars
      //-----------------------------------------------------------------//

      //subscription end date
      varId := GetStatusVariableID(IPS_VAR_Subscription);
      fKernel.VariableManager.WriteVariableString(varId, subscription);

      //live update id
      varId := GetStatusVariableID(IPS_VAR_VersionUpdateIdLive);
      fKernel.VariableManager.WriteVariableInteger(varId, updateIdLive);

      //live update date
      varId := GetStatusVariableID(IPS_VAR_VersionUpdateDateLive);
      fKernel.VariableManager.WriteVariableString(varId, updateDateLive);

      //installed update id
      varId := GetStatusVariableID(IPS_VAR_VersionUpdateIdLocal);
      fKernel.VariableManager.WriteVariableInteger(varId, updateIdLocal);

      //installed update date
      varId := GetStatusVariableID(IPS_VAR_VersionUpdateDateLocal);
      fKernel.VariableManager.WriteVariableString(varId, updateDateLocal);
    end;

end;

//------------------------------------------------------------------------------
//procedure TIPSVersionModule.TestFunction; stdcall;
//begin

 //starten...

//end;

//------------------------------------------------------------------------------
//procedure TIPSVersionModule.TestFunctionParam(Test: Boolean); stdcall;
//begin

 //if Test then
 // raise EIPSModuleObject.Create('Text Exception...!');

//end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.Log(LogText : string);
begin
  fKernel.LogMessage(KL_MESSAGE, 0, GetModuleName(), LogText);
end;

//------------------------------------------------------------------------------
procedure TIPSVersionModule.ReceiveText(Text: String); stdcall;
begin

 //auswerten...

end;

end.
