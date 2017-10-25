unit uTransaction;

interface

uses
  System.SysUtils,
  Generics.Collections,
  uCommon,
  uInput,
  uTail;

type
  TTransaction = class(TObject)
  protected
    inputs: TList<TInput>;
    tails: TList<TTail>;
    pubKey: TVector8;    //  = std::vector<uint8_t>(279, 0);
    signature: TVector8; //  = std::vector<uint8_t>(64, 0);
    class var availibleTxes: TList<TAddedOutput>;
  public
    constructor Create(pubKey: TVector8);

    function getBroadcastData: TVector8;

    function getTxeData: TVector8;

    procedure Clear;

    function addInput(output: TOutput; tail: LongWord; info: TVector8): Boolean;

    function removeInput(output: TOutput; tail: LongWord; info: TVector8): Boolean;

    function addTail(tail: TTail): Boolean;

    function removeTail(tail: TTail): Boolean;

    procedure sign(key: TECDSA_PrivateKey);

    function addAvailibleTxe(output: TOutput; tailsSize: LongWord): Boolean;

    //bool Transaction::scanBroadcastedData(std::vector<uint8_t> data, uint32_t& position)
    function scanBroadcastedData(data: TVector8; position: LongWord): Boolean;

    procedure showInfo;

    function removeSign: Boolean;

    function Equal(ATransaction: TTransaction): Boolean;
  end;

implementation

{ TTransaction }

constructor TTransaction.Create(pubKey: TVector8);
begin
  inputs := TList<TInput>.Create;
  tails := TList<TTail>.Create;

  pubKey := TVector8.Create;
  InitVector(pubKey, 279, 0); // = std::vector<uint8_t>(279, 0);

  signature := TVector8.Create;
  InitVector(signature, 64, 0); // = std::vector<uint8_t>(64, 0);

  pubKey(pub);
end;

{+}
function TTransaction.Equal(ATransaction: TTransaction): Boolean;
var
  i: Integer;
begin
  Result := False;

  if (inputs.Count <> ATransaction.inputs.Count) or
     (tails.Count <> ATransaction.tails.Count) then Exit;

  for i := 0 to inputs.Count-1 do
    if inputs[i] <> ATransaction.inputs[i] then Exit;

  for i := 0 to tails.Count-1 do
    if tails[i] <> tails[i] then Exit;

  if pubKey <> ATransaction.pubKey then Exit;

  if signature <> ATransaction.signature then Exit;

  Result := True;
end;

{+}
function TTransaction.addAvailibleTxe(output: TOutput; tailsSize: LongWord): Boolean;
begin
  availibleTxes.Add(AddedOutput(output, tailsSize));

  Result := true;
end;

{+}
function TTransaction.addInput(output: TOutput; tail: LongWord; info: TVector8): Boolean;
var
  data: TInput;
begin
  data.setOutput(output);
  data.setTailNum(tail);
  data.setHash(info);

  inputs.Add(data);

  Result := true;
end;

{+}
function TTransaction.addTail(tail: TTail): Boolean;
begin
  tails.Add(tail);

  Result := true;
end;

{+}
procedure TTransaction.Clear;
begin
  inputs.Clear;
  tails.Clear;
  signature.Clear;
end;

{+}
function TTransaction.getBroadcastData: TVector8;
var
  inputsAmount: LongWord;
  tailsAmount: LongWord;
  data: TVector8;
  info: TVector8;
  i: Integer;
begin
{
  uint32_t inputsAmount = inputs.size();
  uint32_t tailsAmount = tails.size();
  std::vector<uint8_t> data;
  converter32to8(inputsAmount, data);
  converter32to8(tailsAmount, data);
  std::vector<uint8_t> info = getTxeData();
  for (auto c : info)
    data.push_back(c);
  return data;
}
  inputsAmount := inputs.Count;
  tailsAmount := tails.Count;

  data := TVector8.Create;

  converter32to8(inputsAmount, data);
  converter32to8(tailsAmount, data);

  info := getTxeData;

  for i := 0 to info.Count-1 do data.Add(info[i]);

  Result := data;
end;

{+}
function TTransaction.getTxeData: TVector8;
var
  info: TVector8;
  data: TVector8;
  i: Integer;
  j: Integer;
begin
  info := TVector8.Create;

  for i := 0 to inputs.Count-1 do
    begin
      data := inputs[i].convertTo8;

      for j := 0 to data.Count-1 do
        info.Add(data[j]);
    end;

  for i := 0 to tails.Count-1 do
    begin
      data := tails[i].convertTo8;

      for j := 0 to data.Count-1 do
        info.Add(data[j]);
    end;

  for i := 0 to pubKey.Count-1 do
    info.Add(pubKey[i]);

  for i := 0 to signature.Count-1 do
    info.Add(signature[i]);

  Result := info;
end;

{+}
function TTransaction.removeInput(output: TOutput; tail: LongWord; info: TVector8): Boolean;
var
  i: LongWord;
begin
  for i := 1 to inputs.Count-1 do
    if inputs[i].match(output, tail, info) then
      begin
        inputs.Delete(inputs.begin + i);
        Result := true;
        Exit;
      end;

  Result := false;
end;

{+}
function TTransaction.removeSign: Boolean;
{
var
  ByteArray: array of Byte;
begin
  signature = TVector8.Create;

  SetLength(ByteArray, 64);
  FillChar(ByteArray, 64, 0);
  signature.AddRange(ByteArray);
  SetLength(ByteArray, 0);

  Result := true;
end;
}
begin
  signature = TVector8.Create;

  InitVector(signature, 64, 0);

  Result := true;
end;

{+}
function TTransaction.removeTail(tail: TTail): Boolean;
var
  i: LongWord;
begin
  for i := 1 to tails.Count-1 do
    if tails[i].Equal(tail) then
      begin
        tails.Delete(tails.begin + i);
        Result := True;
        Exit;
      end;

  Result := False;
end;

{+}
function TTransaction.scanBroadcastedData(data: TVector8; position: LongWord): Boolean;
var
  i: Integer;
  input: TInput;
  tail: TTail;
  inputsAmount: LongWord;
  tailsAmout: LongWord;
begin
  inputsAmount := converter8to32(data, position);
  tailsAmout := converter8to32(data, position);

  for i := 0 to inputsAmount-1 do
    begin
      input := TInput.Create;
      input.scan(data, position);
      inputs.Add(input);
    end;

  for i := 0 to tailsAmout-1 do
    begin
      tail := TTail.Create;
      tail.scan(data, position);
      tails.Add(input);
    end;

  pubKey.Clear;

  for i := 0 to 279-1 do
    begin
      pubKey.Add(data[position]);
      Inc(position);
    end;

  signature.Clear;

  for i := 0 to 64-1 do
    begin
      signature.Add(data[position]);
      Inc(position);
    end;

  Result := True;
end;

{+}
procedure TTransaction.showInfo;
var
  OutputText: String;
  i: Integer;
begin
  OutputText := 'Transaction:' + #13#10 +
                'Pubkey: ' + hex_encode(pubKey) + #13#10 +
                'Signature: ' + hex_encode(signature) + #13#10;

  for i := 0 to inputs.Count-1 do
    OutputText := OutputText + inputs[i].Output;

  for i := 0 to tails.Count-1 do
    OutputText := OutputText + tails[i].Output;
end;

procedure TTransaction.sign(key: TECDSA_PrivateKey);
begin
{
  AutoSeeded_RNG rng;
  std::vector<uint8_t> data = this->getTxeData();
  PK_Signer signer(key, rng, "EMSA1(SHA-256)");
  signer.update(data);
  signature = signer.signature(rng);
}
end;

end.
