unit IPSLicense;

interface

uses SysUtils, Windows, Registry;

function GetLastUpdate()    : String;
function GetLastUpdateID()  : Integer;
function GetLicense()       : String;
function GetLimitDemo()     : Integer;
function GetLimitVariables(): Integer;
function GetLimitWebFront() : Integer;
function GetUsername()      : String;


implementation

const
  RegKey                  = '\Software\IP-Symcon';  //REG_SZ
  RegItemLastUpdate       = 'LastUpdate';           //REG_SZ
  RegItemLastUpdateID     = 'LastUpdateID';         //REG_DWORD
  RegItemLicence          = 'Licence';              //REG_SZ
  RegItemLimitDemo        = 'LimitDemo';            //REG_DWORD
  RegItemLimitVariables   = 'LimitVariables';       //REG_DWORD
  RegItemLimitWebFront    = 'LimitWebFront';        //REG_DWORD
  RegItemUsername         = 'Username';             //REG_SZ



function GetRegValueSZ(Item: string) : String;
var
  reg : TRegistry;
  ret : String;
begin
reg := TRegistry.Create(KEY_READ);
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;

    if reg.OpenKey(RegKey, false) then
      begin
        try
          if reg.ValueExists(Item) then
            ret := reg.ReadString(Item);
        finally
          reg.CloseKey;
        end;
      end
    else
      begin
        ret := '';
      end;

    Result := ret;

  finally
    reg.Free;
  end;
end;



function GetRegValueDWORD(Item: string) : Integer;
var
  reg : TRegistry;
  ret : Integer;
begin
reg := TRegistry.Create(KEY_READ);
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;

    if reg.OpenKey(RegKey, false) then
      begin
        try
          if reg.ValueExists(Item) then
            ret := reg.ReadInteger(Item);
        finally
          reg.CloseKey;
        end;
      end
    else
      begin
        ret := 0;
      end;

    Result := ret;

  finally
    reg.Free;
  end;
end;


function GetLastUpdate() : String;
var
  ret : String;
begin
  ret := GetRegValueSZ(RegItemLastUpdate);
  Result := ret;
end;


function GetLastUpdateID() : Integer;
var
  ret : Integer;
begin
  ret := GetRegValueDWORD(RegItemLastUpdateID);
  Result := ret;
end;


function GetLicense() : String;
var
  ret : String;
begin
  ret := GetRegValueSZ(RegItemLicence);
  Result := ret;
end;


function GetLimitDemo() : Integer;
var
  ret : Integer;
begin
  ret := GetRegValueDWORD(RegItemLimitDemo);
  Result := ret;
end;


function GetLimitVariables() : Integer;
var
  ret : Integer;
begin
  ret := GetRegValueDWORD(RegItemLimitVariables);
  Result := ret;
end;


function GetLimitWebFront() : Integer;
var
  ret : Integer;
begin
  ret := GetRegValueDWORD(RegItemLimitWebFront);
  Result := ret;
end;


function GetUsername() : String;
var
  ret : String;
begin
  ret := GetRegValueSZ(RegItemUsername);
  Result := ret;
end;



end.

