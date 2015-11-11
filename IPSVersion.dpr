library IPSVersion;

uses
  SimpleShareMem,
  Windows,
  StrUtils,
  Classes,
  SysUtils,
  UIPSTypes,
  UIPSModuleTypes,
  Internet in 'Internet.pas',
  Tools in 'Tools.pas',
  UIPSVersionModule in 'UIPSVersionModule.pas',
  IPSLicense in 'IPSLicense.pas',
  IPSLive in 'IPSLive.pas';

{$R *.res}

//------------------------------------------------------------------------------
procedure IPSModuleRegister(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall; forward;
procedure IPSModuleUnregister(); stdcall; forward;

//------------------------------------------------------------------------------
const LibInfo: TIPSLibraryInfo = (
                                 mUniqueID    : '{C2577E2D-C045-4496-89F5-F4C6C50DDBC6}';
                                 //--------------------------
                                 mAuthor      : 'PB';
                                 mURL         : '';
                                 mName        : 'PBs Library';
                                 mVersion     : {CompileVersion}$0200{/CompileVersion}; { Hi - MajorV, Lo - MinorV }
                                 mBuild       : {CompileBuild}0{/CompileBuild};
                                 mDate        : {CompileTime}0{/CompileTime};
                                 //--------------------------
                                 mKernelVersion : KERNEL_VERSION;
                                 //--------------------------
                                 fRegister    : IPSModuleRegister;
                                 fUnregister  : IPSModuleUnregister;
                               );

//------------------------------------------------------------------------------
var vKernel: IIPSKernel;

//------------------------------------------------------------------------------
procedure IPSLibraryInfo(var LibraryInfo: PIPSLibraryInfo); stdcall;
begin

 LibraryInfo := @LibInfo;

end;

//------------------------------------------------------------------------------
procedure IPSModuleRegister(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall;
begin

 vKernel := Kernel;
 vKernel.LogMessage(KL_MESSAGE, 0, LibInfo.mName, 'Register');

 //Register Classes
 ModuleRegistry.RegisterModule(TIPSVersionModule, TypeInfo(IIPSVersionModule), 'IPSV');

end;

//------------------------------------------------------------------------------
procedure IPSModuleUnregister(); stdcall;
begin

 vKernel.LogMessage(KL_MESSAGE, 0, LibInfo.mName, 'Unregister');
 vKernel := NIL;

end;

//==============================================================================
exports IPSLibraryInfo;

begin
 //
end.

