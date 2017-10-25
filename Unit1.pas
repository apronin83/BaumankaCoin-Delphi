unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  InpData, OutData: LongWord;

  pInpData: PLongWord;

  LongWordBuff: array[0..3] of Byte absolute InpData;

  Buffer: array [0..3] of Byte;

begin
  InpData := 2147483649;

  Memo1.Lines.Add('[0]=' + IntToStr(LongWordBuff[0]));
  Memo1.Lines.Add('[1]=' + IntToStr(LongWordBuff[1]));
  Memo1.Lines.Add('[2]=' + IntToStr(LongWordBuff[2]));
  Memo1.Lines.Add('[3]=' + IntToStr(LongWordBuff[3]));

  pInpData := @LongWordBuff[0];

  OutData := LongWord(pInpData^);

  Memo1.Lines.Add(IntToStr(OutData));
end;

end.
