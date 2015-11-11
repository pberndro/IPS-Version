unit IPSLive;

interface

uses
  Internet, SysUtils, StrUtils, Classes, Tools;


var
  initialized : Boolean;
  AccessToken : String;
  
  function Login(Username, License : String; LimitVars : Integer) : Boolean;
  
  function GetSubscriptionEnd() : String;
  function GetVersion() : Integer;
  function GetVersionDate() : String;


implementation


  const ipsServer = 'www.ip-symcon.de';
  const userAgent = 'Mozilla/3.0 (compatible; Indy Library)';
  const LoginURL = '/live2/update.php?action=login';
  const AuthOK = 'Authentication: SUCCEED';
  const LiveUpdateReady = 'LIVE UPDATE! Ready';

type

  TUpdateInfo = record
    Valid: String; //Valid
    UpdateID: Integer; //UpdateID
    UpdateTime: String; //UpdateTime

  end;

var

  Info : TUpdateInfo;


function ParseData(data : String) : String;
var
  ret : String;
  position, lng, i : Integer;
  SL : TStringList;
  ItemName, ItemValue : String;
begin
  SL := TStringList.Create;
  SL.Text := data;

  for i := 0 to SL.Count - 1 do
  begin
    ItemName  := trim(copy(SL[i], 0, pos(':', SL[i])-1));
    ItemValue := trim(copy(SL[i], pos(': ', SL[i])+1, MaxInt));

    if UpperCase(ItemName) = 'UPDATETIME' then
      Info.UpdateTime := ItemValue
    else if UpperCase(ItemName) = 'UPDATEID' then
      Info.UpdateID := StrToInt(ItemValue)
    else if UpperCase(ItemName) = 'VALID' then
      Info.Valid := ItemValue;
  end;

end;


// http://www.ip-symcon.de/live2/update.php?action=login
function Login(Username, License : String; LimitVars : Integer) : Boolean;
var
  tmp, hash, data : String;
  today : TDateTime;
  time : String;
  ret : Boolean;
  strpos: Integer;
  sl: TStringlist;
  position : Integer;
  lng : Integer;
begin
  ret := false;

  today := Now;
  time := TimeToStr(today);
  hash := RandomMD5();
  hash := UpperCase(hash);
  
  //when ips license is unlimmited value = 0
  //don't send this value
  if LimitVars <> 0 then

    data :=
    'username=' + Username + '&' +
    'licence=' + License + '&' +
    'limits%5Bvariables%5D='+ IntToStr(LimitVars) + '&' +
    'sessionhash=' + hash

  else

    data :=
    'username=' + Username + '&' +
    'licence=' + License + '&' +
    'sessionhash=' + hash;

  tmp := httpPOST(userAgent, ipsServer, LoginURL, data);

  strpos := Pos(AuthOK, tmp);
  if strpos <> 0 then
  begin
    tmp := Trim(tmp);
    position := Pos(LiveUpdateReady, tmp);
    lng := Length(LiveUpdateReady);

    if position <> 0 then
      Delete(tmp, position, lng);

    ret := true;
    ParseData(tmp);
  end;

  Result := ret;
end;


function GetSubscriptionEnd() : String;
var
  ret : String;
begin
  ret := '';

  if Length(Info.Valid) > 0 then
    ret := Info.Valid;

  Result := ret;
end;


function GetVersion() : Integer;
var
  ret : Integer;
begin
   ret := 0;

   if Info.UpdateID > 0 then
    ret := Info.UpdateID;

  Result := ret;
end;


function GetVersionDate() : String;
var
  ret : String;
begin
  ret := '';

  if length(Info.UpdateTime) > 0 then
    ret := Info.UpdateTime;

  Result := ret;
end;

{
LIVE UPDATE! Ready
ReqClientVer: 1.0
Authentication: SUCCEED
Session: e0vlqv4ut6saj6hs0i3cce1i30
Valid: 31.07.14
UpdateID: 3434
UpdateTime: 21.05.14
}


end.

