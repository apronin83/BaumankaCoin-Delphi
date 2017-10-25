unit uBlock;

interface

uses
  System.SysUtils, Generics.Collections,
  uCommon,
  uTransaction,
  uTail;

type
  TBlock = class(TObject)
  protected
    version: LongWord; // = 1; // default value
    prevBlock: TSecureVector; //= Botan::secure_vector<uint8_t>(32, 0); // hash
    currentNumber: LongWord; // = 0;
    merkleRoot: TSecureVector; // = Botan::secure_vector<uint8_t>(32, 0);
    bits: LongWord; // = 1;              // Proof of work difficulty
    nonce: LongWord; // = 0;             // to change hash
    txsCount: LongWord; // = 0;          // hash untill this
    txs: TList<TTransaction>; // static pool for non validated txes

    procedure setHash(from: TVector8; position: LongWord; v_to: TSecureVector);
  public
    class var nonValidated: TList<TTransaction>;

    function getBlockData: TVector8;
    function getTxeData(num: LongWord): TVector8;
    function getBroadcastData: TVector8;
    function getCurrentNumber: LongWord;
    function addFirstTxe(address: TSecureVector): Boolean;
    function addTransaction(num: LOngWord): Boolean;
    procedure setPrevBlock(data: TVector8);
    procedure setMerkleRoot;
    procedure broadcastBlock;
    function scanBroadcastedData(data: TVector8; position: LongWord): Boolean;
    procedure setNumber(num: LongWord);
    function showInfo: String;
  end;


implementation

{ TBlock }

{+}
function TBlock.addFirstTxe(address: TSecureVector): Boolean;
var
  first: TTransaction;
  tail: TTail;
begin
  if (txs.Count <> 0) or (txsCount <> 0) then
    begin
      Result := false;
      Exit;
    end;

  tail := TTail.Create(100, address); // HARDCODED NUMBER

  first.addTail(tail);

  txs.Add(first);

  Inc(txsCount);

  Result := True;
end;

{+/-}
function TBlock.addTransaction(num: LOngWord): Boolean;
begin
  Result := False;

  if (num < nonValidated.Count) and (txs.Count < 8) then// 8 txs in a block maximum
    begin
      txs.Add(nonValidated[num]);
      //txs.Delete(nonValidated.begin + num); // ORIGINAL
      txs.Delete(num);                        // MINE
      Result := True;
    end;
end;

{+}
procedure TBlock.broadcastBlock;
begin
  // В оригинале метод пустой
end;

{+}
function TBlock.getBlockData: TVector8;
var
  i: Integer;
  data: TVector8;
begin
  converter32to8(version, data);

  for i := 0 to prevBlock.Count-1 do
    data.Add(prevBlock[i]);

  converter32to8(currentNumber, data);

  for i := 0 to merkleRoot.Count-1 do
    data.Add(merkleRoot[i]);

  converter32to8(bits, data);
  converter32to8(nonce, data);
  converter32to8(txsCount, data);

  Result := data;
end;

{+}
function TBlock.getBroadcastData: TVector8;
var
  i, j: Integer;
  data: TVector8;
  info: TVector8;
begin
  data := getBlockData;

  for i := 0 to txs.Count-1 do
    begin
      info := txs[i].getBroadcastData;

      for j := 0 to info.Count-1 do
        data.Add(info[j]);
    end;

  Result :=  data;
end;

{+}
function TBlock.getCurrentNumber: LongWord;
begin
  Result := currentNumber;
end;

{+}
function TBlock.getTxeData(num: LongWord): TVector8;
begin
  Assert(num < txs.Count); // change for exceptions

  Result := txs[num].getTxeData;
end;

{+}
function TBlock.scanBroadcastedData(data: TVector8; position: LongWord): Boolean;
var
  i: Integer;
  txn: TTransaction;
begin
  version := converter8to32(data, position);
  setHash(data, position, prevBlock);
  currentNumber := converter8to32(data, position);
  setHash(data, position, merkleRoot);
  bits := converter8to32(data, position);
  nonce := converter8to32(data, position);
  txsCount := converter8to32(data, position);

  for i := 0 to txsCount-1 do
    begin
      txn := TTransaction.Create;
      txn.scanBroadcastedData(data, position);
      txs.Add(txn);
    end;

  Result := true;
end;

{+}
procedure TBlock.setHash(from: TVector8; position: LongWord; v_to: TSecureVector);
var
  i: LongWord;
begin
  v_to.Clear;

  for i := 0 to 32-1 do v_to.Add(from[position + i]);

  Inc(position, 32);
end;

{+/-}
procedure TBlock.setMerkleRoot;
var
  i: LongWord;
  tempData: TSecureVector;
  hashes: TVectorOfSecureVector;
  tempHashes: TVectorOfSecureVector;
begin
  Result := False;

  if (txs.Count = 1) or
     (txs.Count = 2) or
     (txs.Count = 4) or
     (txs.Count = 8) then // HARDCODE
    begin
      hashes := TVector8.Create;

      for i := 0 to txs.Count-1 do
        hashes.Add(SHA_256().process(txs[i].getTxeData()));

      while hashes.Count <> 1 do
        begin
          tempHashes := TVectorOfSecureVector.Create;

          for i := 0 to hashes.Count-1 do
            begin
              if i mod 2 = 1 then
                begin
                  tempData := hashes[i - 1];

                  for j := 0 to hashes[i].Count-1 do
                    tempData.Add(hashes[i][j]);

                  tempHashes.Add(SHA_256().process(tempData));
                end;

              hashes := tempHashes;
            end;
        end;

      merkleRoot = hashes[0];

      Result := True;
    end;
end;

{+}
procedure TBlock.setNumber(num: LongWord);
begin
  currentNumber := num;
end;

{+/-}
procedure TBlock.setPrevBlock(data: TVector8);
begin
  prevBlock := SHA_256().process(data);
end;

{+}
function TBlock.showInfo: String;
var
  i: LongWord;
begin
  Result := 'Block: ' + #13#10;
  Result := Result + 'version: ' + IntToStr(version) + #13#10;
  Result := Result + 'Current number: ' + IntToStr(currentNumber) + #13#10;
  Result := Result + 'Bits: ' + IntToStr(bits) + #13#10;
  Result := Result + 'Nonce: ' + IntToStr(nonce) + #13#10;
  Result := Result + 'Transaction count: ' + IntToStr(txsCount) + #13#10;
  Result := Result + 'Merkle root: ' + hex_encode(merkleRoot) + #13#10;

  for i := 0 to txs.Count-1 do
    Result := Result + txs[i].showInfo;
end;

end.
