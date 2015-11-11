unit Tools;

interface

uses SysUtils, Math;

function ROT13(Str: string) : String;
function RandomMD5(): string;

implementation

function ROT13(Str: string) : String;
const
  OrdBigA = Ord('A');
  OrdBigZ = Ord('Z');
  OrdSmlA = Ord('a');
  OrdSmlZ = Ord('z');
var
  i, o: integer;
begin
  for i := 1 to length(Str) do
  begin
    o := Ord(Str[i]);
    if InRange(o, OrdBigA, OrdBigZ) then
      Str[i] := Chr(OrdBigA + (o - OrdBigA + 13) mod 26)
    else if InRange(o, OrdSmlA, OrdSmlZ) then
      Str[i] := Chr(OrdSmlA + (o - OrdSmlA + 13) mod 26);
  end;
  result := Str;
end;


function RandomMD5(): string;
var
  str: string;
begin
  Randomize;
  //string with all possible chars
  str    := 'abcdef1234567890';
  Result := '';
  repeat
    Result := Result + str[Random(Length(str)) + 1];
  until (Length(Result) = 32)
end;


end.

