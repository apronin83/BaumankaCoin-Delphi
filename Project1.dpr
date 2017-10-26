program Project1;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uTransaction in 'uTransaction.pas',
  uTail in 'uTail.pas',
  uCommon in 'uCommon.pas',
  uInput in 'uInput.pas',
  uOutput in 'uOutput.pas',
  uBlock in 'uBlock.pas',
  uBlockchain in 'uBlockchain.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
