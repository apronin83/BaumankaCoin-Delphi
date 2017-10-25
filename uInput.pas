unit uInput;

interface

uses
  System.SysUtils,
  Generics.Collections,
  uCommon,
  uOutput;

type
  TInput = class(TObject)
  private
    output: TOutput;
    outputHash: TSecureVector; // Botan::secure_vector<uint8_t> outputHash = Botan::secure_vector<uint8_t>(32, 0);
    tailNum: LongWord; // = 0;
  public
    constructor Create;

    procedure setOutput(blockNum: LongWord; txeNum: LongWord); overload;

    procedure setOutput(v_out: TOutput); overload;

    procedure setHash(info: TVector8);

    procedure setTailNum(num: LongWord);

    function scan(data: TVector8; position: LongWord): Boolean;

    function match(v_out: TOutput; tail: LongWord; info: TVector8): Boolean;

    function getInfo: TPair<TOutput, LongWord>;

    function convertTo8: TVector8;

    function Equal(AInput: TInput): Boolean;

    function OutputMethod(AInput: TInput): String;
  end;

implementation

{ TInput }

{+}
constructor TInput.Create;
begin
  tailNum := 0;
end;

{+}
function TInput.convertTo8: TVector8;
var
  i: LongWord;
  v_to: TVector8;
begin
{
  std::vector<uint8_t> to;
  converter32to8(output.blockNumber, to);
  converter32to8(output.txeNumber, to);
  for (auto i : outputHash)
    to.push_back(i);
  converter32to8(tailNum, to);
  return to;
}

  v_to := TVector8.Create;

  converter32to8(output.blockNumber, v_to);
  converter32to8(output.txeNumber, v_to);

  for i := 0 to outputHash.Count-1 do
    v_to.Add(outputHash[i]);

  converter32to8(tailNum, v_to);

  Result := v_to;
end;

{+}
function TInput.Equal(AInput: TInput): Boolean;
begin
{
   return output == AInput.output && outputHash == AInput.outputHash
         && tailNum == AInput.tailNum;
}
  Result := output.Equal(AInput.output) and
            outputHash.Equal(AInput.outputHash) and
            (tailNum = AInput.tailNum);
end;

{+}
function TInput.getInfo: TPair<TOutput, LongWord>;
begin
  Result := TPair<TOutput, LongWord>.Create(output, tailNum);
end;

{+/-}
function TInput.match(v_out: TOutput; tail: LongWord; info: TVector8): Boolean;
begin
{
  return !(out != output || tail != tailNum
           || SHA_256().process(info) != outputHash);
}
  Result := not ((not v_out.Equal(output)) or
                 (tail <> tailNum) or
                 (not SHA_256().process(info).Equal(outputHash))
                 );
end;

{+}
function TInput.scan(data: TVector8; position: LongWord): Boolean;
var
  i: Integer;
begin
(*
{
  output.blockNumber = converter8to32(data, position);
  output.txeNumber = converter8to32(data, position);
  outputHash.clear();
  for (uint32_t i = 0; i < 32; i++)
    {
      outputHash.push_back(data[position]);
      position++;
    }
  tailNum = converter8to32(data, position);
  return true;
}
*)
  output.blockNumber := converter8to32(data, position);
  output.txeNumber := converter8to32(data, position);

  outputHash.clear();

  for i := 0 to 32 do
    begin
      outputHash.Add(data[position]);
      Inc(position);
    end;

  tailNum := converter8to32(data, position);

  Result := True;
end;

{-}
procedure TInput.setHash(info: TVector8);
begin
//  outputHash = SHA_256().process(info);
end;

{+}
procedure TInput.setOutput(blockNum, txeNum: LongWord);
begin
  output := TOutput.Create(blockNum, txeNum);
end;

{+}
procedure TInput.setOutput(v_out: TOutput);
begin
  output := v_out;
end;

{+}
procedure TInput.setTailNum(num: LongWord);
begin
  tailNum := num;
end;

{+/-}
function TInput.OutputMethod(AInput: TInput): String;
begin
  Result := 'Input:' + AInput.output.OutputMethod + #13#10 +
            'Output hash: ' + hex_encode(AInput.outputHash);
end;

end.
