program WOW;

uses
  Vcl.Forms,
  UtMain in 'UtMain.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
