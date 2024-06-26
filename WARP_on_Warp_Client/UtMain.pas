unit UtMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls,madKernel,System.Win.Registry,
  RzTabs, IdBaseComponent, IdThreadComponent, Vcl.Imaging.jpeg,RzLabel,System.IniFiles,
  Vcl.ComCtrls, dxSkinsCore, dxSkinBasic, dxSkinBlack, dxSkinBlue,
  dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkroom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinOffice2019Black, dxSkinOffice2019Colorful, dxSkinOffice2019DarkGray,
  dxSkinOffice2019White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringtime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinTheBezier,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxCore, cxClasses, cxLookAndFeels,
  dxSkinsForm;



type
  TfrmMain = class(TForm)
    SysTray: TTrayIcon;
    TrayMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    MainPage: TRzPageControl;
    TabSheet1: TRzTabSheet;
    TabSheet2: TRzTabSheet;
    TabSheet3: TRzTabSheet;
    Label1: TLabel;
    loginfo: TMemo;
    btnExit: TButton;
    btnStart: TButton;
    btnStop: TButton;
    chbGool: TCheckBox;
    CaptureThread: TIdThreadComponent;
    logo: TImage;
    chbIPv6: TCheckBox;
    chbIPv4: TCheckBox;
    chbpsiphon: TCheckBox;
    GBLicense: TGroupBox;
    chbLicense: TCheckBox;
    lblLicense: TLabel;
    edtLicense: TEdit;
    chbSystemProxy: TCheckBox;
    FooterBar: TStatusBar;
    lblYousef: TRzLabel;
    LogScroll: TTimer;
    Skin: TdxSkinController;
    procedure btnStartClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure CaptureThreadRun(Sender: TIdThreadComponent);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SysTrayDblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure chbIPv6Click(Sender: TObject);
    procedure chbIPv4Click(Sender: TObject);
    procedure chbGoolClick(Sender: TObject);
    procedure chbpsiphonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chbLicenseClick(Sender: TObject);
    procedure edtLicenseChange(Sender: TObject);
    procedure chbSystemProxyClick(Sender: TObject);
    procedure LogScrollTimer(Sender: TObject);
  private
    { Private declarations }
  public
  procedure RunProcessAndCaptureOutput(const CmdLine: string; Memo: TMemo; HideLinesCount: Integer = 0);
  function SetSystemProxy(const ProxyIP: string; ProxyPort: Word): Boolean;
  function RemoveSystemProxy: Boolean;
  procedure ScrollToLastLine(Memo: TMemo);

end;


var
 frmMain: TfrmMain;
 SettingFile:TIniFile;
 License:string;

implementation

const
  ProxyRegKey = 'Software\Microsoft\Windows\CurrentVersion\Internet Settings';


{$R *.dfm}


//==============================================================================

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
 CaptureThread.Stop;
 Processes('warp.exe').Terminate(0);
 RemoveSystemProxy;
 Application.Terminate;
end;

//==============================================================================

procedure TfrmMain.btnStartClick(Sender: TObject);
begin


 loginfo.Clear;
 if not FileExists(ExtractFilePath(Application.ExeName) + '\warp.exe') then
   MessageBox(self.Handle,'Can''t find "warp.exe"','Error',MB_ICONERROR)
 else
   begin
    btnStart.Enabled := False;
    btnStop.Enabled  := True;
    MainPage.Pages[0].Show;

    CaptureThread.Start;
   end;
end;

//==============================================================================

procedure TfrmMain.btnStopClick(Sender: TObject);
begin
 CaptureThread.Terminate;
 Processes('warp.exe').Terminate(0);
 loginfo.Clear;
 RemoveSystemProxy;
 btnStop.Enabled := False;
 btnStart.Enabled := True;
end;

//==============================================================================

procedure TfrmMain.CaptureThreadRun(Sender: TIdThreadComponent);
var
 Params:string;
 Gool,IPv4,IPv6,psiphon,lic:Boolean;
begin
 Params  := '';
 Gool    := chbGool.Checked;
 IPv4    := chbIPv4.Checked;
 IPv6    := chbIPv6.Checked;
 psiphon := chbpsiphon.Checked;
 lic     := chbLicense.Checked;



 if IPv4 then
  Params := Params + '-4 ';
 if IPv6 then
  Params := Params + '-6 ';
 if psiphon then
  Params := Params + '--cfon ';
 if Gool then
  Params := Params + '--gool ';
 if (lic) and (Length(Trim(edtLicense.Text)) <> 0) then
  Params := Params + '--key ' +  edtLicense.Text ;




 RunProcessAndCaptureOutput(ExtractFilePath(Application.ExeName) + '\warp.exe ' + Params,loginfo);

end;

//==============================================================================

procedure TfrmMain.chbGoolClick(Sender: TObject);
begin
 if chbGool.Checked = True then
   begin
    SettingFile.WriteString('Settings','WoW','True');
    chbpsiphon.Checked := False;
    chbpsiphon.Enabled := False;
   end
 else
    begin
    SettingFile.WriteString('Settings','WoW','True');
    chbpsiphon.Checked := False;
    chbpsiphon.Enabled := True;
   end;
end;

//==============================================================================

procedure TfrmMain.chbIPv4Click(Sender: TObject);
begin
 if chbIPv4.Checked = True then
   begin
    SettingFile.WriteString('Settings','IPv6','True');
    chbIPv6.Checked := False;
    chbIPv6.Enabled := False;
   end
 else
   begin
    SettingFile.WriteString('Settings','IPv6','False');
    chbIPv6.Checked := False;
    chbIPv6.Enabled := True;
   end
end;

//==============================================================================

procedure TfrmMain.chbIPv6Click(Sender: TObject);
begin
 if chbIPv6.Checked = True then
   begin
    SettingFile.WriteString('Settings','IPv4','True');
    chbIPv4.Checked := False;
    chbIPv4.Enabled := False;
   end
 else
   begin
    SettingFile.WriteString('Settings','IPv4','False');
    chbIPv4.Checked := False;
    chbIPv4.Enabled := True;
   end
end;

//==============================================================================

procedure TfrmMain.chbLicenseClick(Sender: TObject);
begin
 if chbLicense.Checked then
 begin
  edtLicense.Enabled := True;
  lblLicense.Enabled := True;
  SettingFile.WriteString('Settings','LicActivation','True');
  edtLicense.Text := SettingFile.ReadString('Settings','License','');
 end else
 begin
   edtLicense.Enabled := False;
   lblLicense.Enabled := False;
   SettingFile.WriteString('Settings','LicActivation','False');
 end;

end;

//==============================================================================

procedure TfrmMain.chbpsiphonClick(Sender: TObject);
begin
 if chbpsiphon.Checked = True then
   begin
    SettingFile.WriteString('Settings','psiphon','True');
    chbGool.Checked := False;
    chbGool.Enabled := False;
   end
 else
   begin
    SettingFile.WriteString('Settings','psiphon','False');
    chbGool.Checked := False;
    chbGool.Enabled := True;
   end
end;

//==============================================================================

procedure TfrmMain.chbSystemProxyClick(Sender: TObject);
begin
 if chbSystemProxy.Checked then
 begin
    if not SetSystemProxy('127.0.0.1',8086) then
      MessageBoxA(Self.Handle,'Can''t set system proxy','Error',MB_ICONERROR);
 end else
 begin
   if not RemoveSystemProxy then
    MessageBoxA(Self.Handle,'Can''t change system proxy','Error',MB_ICONERROR);
 end;
end;

//==============================================================================

procedure TfrmMain.edtLicenseChange(Sender: TObject);
begin
 SettingFile.WriteString('Settings','License',edtLicense.Text);
end;

//==============================================================================

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Hide();
  SysTray.Visible := True;
  CanClose := False;
end;

//==============================================================================

procedure TfrmMain.FormShow(Sender: TObject);
var
 WoW,IP4,IP6,Cfon,License,LicAvtivation:String;
begin
 SettingFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Setting.ini');
 WoW  := SettingFile.ReadString('Settings','WoW',WoW);

 if WoW = 'True' then chbGool.Checked := True else chbGool.Checked := False;

 IP4  := SettingFile.ReadString('Settings','IPv4',IP4);
 if IP4 = 'True' then chbIPv4.Checked := True else chbIPv4.Checked := False;

 IP6  := SettingFile.ReadString('Settings','IPv6',IP6);
 if IP6 = 'True' then chbIPv6.Checked := True else chbIPv6.Checked := False;

 Cfon := SettingFile.ReadString('Settings','psiphon',Cfon);
 if Cfon = 'True' then chbLicense.Checked := True else chbLicense.Checked := False;

 License := SettingFile.ReadString('Settings','License',License);
 LicAvtivation := SettingFile.ReadString('Settings','LicActivation',LicAvtivation);

 if (Length(Trim(License)) <> 0) and (LicAvtivation = 'True') then
 begin
   chbLicense.Checked := True;
   edtLicense.Text := License;
 end else
     begin
       chbLicense.Checked := False;
       edtLicense.Text := License;
     end;
end;

//==============================================================================

procedure TfrmMain.LogScrollTimer(Sender: TObject);
begin
SendMessage(loginfo.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
end;

//==============================================================================

procedure TfrmMain.N1Click(Sender: TObject);
begin

 if not SetSystemProxy('127.0.0.1',8086) then
  MessageBoxA(Self.Handle,'Can''t set system proxy','Error',MB_ICONERROR);
end;

//==============================================================================

procedure TfrmMain.N2Click(Sender: TObject);
begin
 if not RemoveSystemProxy then
  MessageBoxA(Self.Handle,'Can''t change system proxy','Error',MB_ICONERROR);
end;

//==============================================================================


procedure TfrmMain.N5Click(Sender: TObject);
begin
 CaptureThread.Stop;
 Processes('warp.exe').Terminate(0);
 Application.Terminate;
end;

//==============================================================================

function TfrmMain.RemoveSystemProxy: Boolean;
var
  Reg: TRegistry;
begin
  Result := False;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if Reg.OpenKey(ProxyRegKey, True) then
    begin
      // Disable proxy
      Reg.WriteInteger('ProxyEnable', 0);

      // Clear proxy server and port
      Reg.DeleteValue('ProxyServer');

      // Apply the changes
      Result := True;
    end;
  finally
    Reg.Free;
  end;
end;

//==============================================================================

procedure TfrmMain.RunProcessAndCaptureOutput(const CmdLine: string;
  Memo: TMemo; HideLinesCount: Integer);
var
  SecAttr: TSecurityAttributes;
  PipeR, PipeW: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: packed array[0..4096-1] of AnsiChar;
  Count: Cardinal;
  S, Leftover: AnsiString;
  i, P: Cardinal;
  C: AnsiChar;
begin
  SecAttr.nLength:=SizeOf(SecAttr);
  SecAttr.lpSecurityDescriptor:=nil;
  SecAttr.bInheritHandle:=True;
  if not CreatePipe(PipeR, PipeW, @SecAttr, 0) then
    raise Exception.Create('CreatePipe: '+SysErrorMessage(GetLastError));
  SetHandleInformation(PipeR, HANDLE_FLAG_INHERIT, 0);
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb:=SizeOf(StartupInfo);
  StartupInfo.dwFlags:=STARTF_USESTDHANDLES;
  StartupInfo.hStdOutput:=PipeW;
  StartupInfo.hStdError:=PipeW;
  FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);
  if not CreateProcess(nil, PChar(CmdLine), nil, nil, True, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
    raise Exception.Create('CreateProcess: '+SysErrorMessage(GetLastError));
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);
  CloseHandle(PipeW);
  Leftover:='';
  while ReadFile(PipeR, Buffer[0], SizeOf(Buffer)-1, Count, nil) and (Count > 0) do
  begin
    Buffer[Count]:=#0;
    i:=0;
    P:=0;
    while i < Count do
    begin
      C:=Buffer[i];
      if C in [#10, #13] then
      begin
        if HideLinesCount > 0 then
          Dec(HideLinesCount)
        else
        begin
          Buffer[i]:=#0;
          S:=Leftover+AnsiString(PAnsiChar(@Buffer[P]));
          OemToCharBuffA(@S[1], @S[1], Length(S));
          Memo.Lines.Add(string(S));
        end;
        Leftover:='';
        case C of
          #10: if Buffer[i+1] = #13 then Inc(i);
          #13: if Buffer[i+1] = #10 then Inc(i);
        end;
        P:=i+1;
      end;
      Inc(i);
    end;
    Leftover:=AnsiString(PAnsiChar(@Buffer[P]));
    Application.ProcessMessages;
  end;
  if (Leftover <> '') and (HideLinesCount <= 0) then
  begin
    OemToCharBuffA(@Leftover[1], @Leftover[1], Length(Leftover));
    Memo.Lines.Add(string(Leftover));
  end;
  CloseHandle(PipeR);
end;

//==============================================================================

procedure TfrmMain.ScrollToLastLine(Memo: TMemo);
begin
  SendMessage(Memo.Handle, EM_LINESCROLL, 0,Memo.Lines.Count);
end;

function TfrmMain.SetSystemProxy(const ProxyIP: string;
  ProxyPort: Word): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if Reg.OpenKey(ProxyRegKey, True) then
    begin
      // Enable proxy
      Reg.WriteInteger('ProxyEnable', 1);

      // Set proxy server and port
      Reg.WriteString('ProxyServer', ProxyIP + ':' + IntToStr(ProxyPort));

      // Apply the changes
      Result := True;
    end;
  finally
    Reg.Free;
  end;
end;

//==============================================================================

procedure TfrmMain.SysTrayDblClick(Sender: TObject);
begin
  Show();
  MainPage.ActivePageIndex := 0 ;
  SysTray.Visible := False;
  Application.Restore();
end;

//==============================================================================
end.
