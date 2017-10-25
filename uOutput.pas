unit uOutput;

interface

uses
  System.SysUtils, Generics.Collections,
  uCommon;

type
  TOutput = class(TObject)
  private

  public
    constructor Create(blockNum: LongWord; txeNum: LongWord);

    function NotEqual(AOutput: TOutput): Boolean;
    function Equal(AOutput: TOutput): Boolean;

    function OutputMethod(AOutput: TOutput): String;
  public
    blockNumber: LongWord;
    txeNumber: LongWord;
  end;

implementation

{ TOutput }

constructor TOutput.Create(blockNum, txeNum: LongWord);
begin
  blockNumber := 0;
  txeNumber := 0;

  blockNumber := blockNum;
  txeNumber := txeNum;
end;

function TOutput.Equal(AOutput: TOutput): Boolean;
begin
  Result := not NotEqual(AOutput);
end;

function TOutput.NotEqual(AOutput: TOutput): Boolean;
begin
  Result := (blockNumber <> AOutput.blockNumber) or
            (txeNumber <> AOutput.txeNumber);
end;

function TOutput.OutputMethod(AOutput: TOutput): String;
begin
  Result := Format('Output: '#13#10'block: %d'#13#10'ttx: %d',
                   [AOutput.blockNumber, AOutput.txeNumber]);
end;

end.
