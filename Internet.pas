unit Internet;

interface

uses
  WinInet, SysUtils;

  function httpGET(const UserAgent: string; const Server: string; const Resource: string): string;
  //function httpsGET(const UserAgent: string; const Server: string; const Resource: string): string;

  function httpPOST(const UserAgent: string; const Server: string; const Resource: string; const Data: AnsiString) : String;
  function httpsPOST(const UserAgent: string; const Server: string; const Resource: string; const Data: AnsiString) : String;

implementation

function httpGET(const UserAgent: string; const Server: string; const Resource: string): string;
var
  hInet: HINTERNET;
  hURL: HINTERNET;
  Buffer: array[0..1023] of AnsiChar;
  i, BufferLen: cardinal;
begin
  result := '';
  hInet := InternetOpen(PChar(UserAgent), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    hURL := InternetOpenUrl(hInet, PChar('http://' + Server + Resource), nil, 0, 0, 0);
    try
      repeat
        InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen);
        if BufferLen = SizeOf(Buffer) then
          result := result + AnsiString(Buffer)
        else if BufferLen > 0 then
          for i := 0 to BufferLen - 1 do
            result := result + Buffer[i];
      until BufferLen = 0;
    finally
      InternetCloseHandle(hURL);
    end;
  finally
    InternetCloseHandle(hInet);
  end;
end;


//ToDo: check if HTTP staus code is 200
function httpPOST(const UserAgent: string; const Server: string; const Resource: string; const Data: AnsiString) : String;// overload;
var
  hInet: HINTERNET;
  hHTTP: HINTERNET;
  hReq: HINTERNET;
  Buffer: array[0..1023] of AnsiChar;
  i, BufferLen: Cardinal;
  ret: String;

const
  accept: packed array[0..1] of PAnsiChar = (PChar('*/*'), nil);
  header: string = 'Content-Type: application/x-www-form-urlencoded';
begin
  hInet := InternetOpen(PChar(UserAgent), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    hHTTP := InternetConnect(hInet, PChar(Server), INTERNET_DEFAULT_HTTP_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 1);
    try
      hReq := HttpOpenRequest(hHTTP, PChar('POST'), PChar(Resource), nil, nil, @accept, 0, 1);
      try
        if not HttpSendRequest(hReq, PChar(header), length(header), PChar(Data), length(Data)) then
          raise Exception.Create('HttpOpenRequest failed. ' + SysErrorMessage(GetLastError));
           repeat
              InternetReadFile(hReq, @Buffer, SizeOf(Buffer), BufferLen);

              if BufferLen = SizeOf(Buffer) then
                Result := ret + AnsiString(Buffer)

              else if BufferLen > 0 then

              for i := 0 to BufferLen - 1 do
                ret := ret + Buffer[i];
              until BufferLen = 0;

              Result := ret;

      finally
        InternetCloseHandle(hReq);
      end;
    finally
      InternetCloseHandle(hHTTP);
    end;
  finally
    InternetCloseHandle(hInet);
  end;
end;


//ToDo: check if HTTP staus code is 200
function httpsPOST(const UserAgent: string; const Server: string; const Resource: string; const Data: AnsiString) : String;// overload;
var
  hInet: HINTERNET;
  hHTTP: HINTERNET;
  hReq: HINTERNET;
  Buffer: array[0..1023] of AnsiChar;
  i, BufferLen: Cardinal;
  ret: String;

const
  accept: packed array[0..1] of PAnsiChar = (PChar('*/*'), nil);
  header: string = 'Content-Type: application/x-www-form-urlencoded';
begin
  hInet := InternetOpen(PChar(UserAgent), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    hHTTP := InternetConnect(hInet, PChar(Server), INTERNET_DEFAULT_HTTPS_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 1);
    try
      hReq := HttpOpenRequest(hHTTP, PChar('POST'), PChar(Resource), nil, nil, @accept, INTERNET_FLAG_SECURE, 1);
      try
        if not HttpSendRequest(hReq, PChar(header), length(header), PChar(Data), length(Data)) then
          raise Exception.Create('HttpOpenRequest failed. ' + SysErrorMessage(GetLastError));
           repeat
              InternetReadFile(hReq, @Buffer, SizeOf(Buffer), BufferLen);

              if BufferLen = SizeOf(Buffer) then
                Result := ret + AnsiString(Buffer)

              else if BufferLen > 0 then

              for i := 0 to BufferLen - 1 do
                ret := ret + Buffer[i];
              until BufferLen = 0;

              Result := ret;

      finally
        InternetCloseHandle(hReq);
      end;
    finally
      InternetCloseHandle(hHTTP);
    end;
  finally
    InternetCloseHandle(hInet);
  end;
end;


end.
