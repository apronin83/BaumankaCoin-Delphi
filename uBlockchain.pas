unit uBlockchain;

interface

uses
  System.SysUtils,
  Generics.Collections,
  uCommon,
  uTransaction,
  uBlock,
  uOutput;

type
  TBlockchain = class(TObject)
  private
    constructor Create;

    class var _self: TBlockchain;

    bits: LongWord; // = 1;

    function validateBlock(block: TBlock): Boolean;

    function validateMerkleRoot(block: TBlock): Boolean;

    function validateFirstTxn(txn: TTransaction): Boolean;

    // returns amount of money taken from inputs
    function validateInputs(txn: TTransaction; toRestore: TList<TPair<TOutput, LongWord>>): LongWord;

    function validateSignature(txn: TTransaction): Boolean;

    function validateTails(txn: TTransaction; sum: LongWord): Boolean;

    procedure restore(toRestore: TList<TPair<TOutput, LongWord>>);

    procedure setAvailibleTxes(block: TBlock);

    procedure clearAvailibleTxes;

    procedure clearNonValidated(block: TBlock);
  private
    FblockChain: TList<TBlock>;
    FnonValidatedBlockChain: TList<TBlock>;
  public
    procedure getBlockchain;

    procedure getNonValidatedTxes;

    function validateBlockChain: Boolean;

    function size: LongWord;

    function addBlock(block: TBlock): Boolean;

    procedure customize(numberOfBlocks: LongWord; address: TSecureVector);

    class function instance: TBlockchain;

    function validateTxn(txn: TTransaction; toRestore: TList<TPair<TOutput, LongWord>>): Boolean;

    function getLastBlockHash: TSecureVector;

    function getBlockchainSize: LongWord;

    function getBlocksAfter(idx: Int64): TList<TBlock>;

    function findByHash(hash: TSecureVector): Int64;

    procedure addTx(tx: TTransaction);

    function getLastBlockData: TVector8;
  end;

implementation

{ TBlockchain }

function TBlockchain.addBlock(block: TBlock): Boolean;
begin
  Result := False;

  if validateBlock(block) then
    begin
      BlockchainMutex->lock();
      FblockChain.Add(block);
      BlockchainMutex->unlock();
      Result := True;
    end;
end;

procedure TBlockchain.addTx(tx: TTransaction);
begin

end;

procedure TBlockchain.clearAvailibleTxes;
var
  i, j: LongWord;
  toRemove: Boolean;
begin
  for i := 0 to TTransaction.availibleTxes.Count-1 do
    begin
      toRemove := true;

      for j := 0 to TTransaction.availibleTxes[i].usedTails.Count-1 do
        toRemove := TTransaction.availibleTxes[i].usedTails[j] and toRemove;

      if (toRemove)
        TTransaction.availibleTxes.Delete(TTransaction::availibleTxes.begin() + i);
    end;
end;

{+/-}
procedure TBlockchain.clearNonValidated(block: TBlock);
var
  j, i: LongWord;
begin
  TransactionsMutex->lock();

  for j := 0 to block.txs.Count-1 do
    for i := 0 to TBlock.nonValidated.Count-1 do
      if TBlock.nonValidated[i] = block.txs[j] then
        TBlock.nonValidated.Delete(TBlock.nonValidated.begin() + i);

  TransactionsMutex->unlock();
end;

constructor TBlockchain.Create;
begin

end;

procedure TBlockchain.customize(numberOfBlocks: LongWord; address: TSecureVector);
begin

end;

function TBlockchain.findByHash(hash: TSecureVector): Int64;
begin

end;

procedure TBlockchain.getBlockchain;
begin

end;

function TBlockchain.getBlockchainSize: LongWord;
begin

end;

function TBlockchain.getBlocksAfter(idx: Int64): TList<TBlock>;
begin

end;

{+}
function TBlockchain.getLastBlockData: TVector8;
begin
  Result := FblockChain.back.getBlockData;
end;

function TBlockchain.getLastBlockHash: TSecureVector;
begin

end;

procedure TBlockchain.getNonValidatedTxes;
begin

end;

{+}
class function TBlockchain.instance: TBlockchain;
begin
  if not Assigned(_self) then
    _self := TBlockchain.Create;

  Result := _self;
end;

procedure TBlockchain.restore(toRestore: TList<TPair<TOutput, LongWord>>);
begin

end;

{+}
procedure TBlockchain.setAvailibleTxes(block: TBlock);
var
  i: LongWord;
begin
  for i := 0 to block.txs.Count-1 do
    block.txs[i].addAvailibleTxe(TOutput.Create(block.currentNumber, i),
                                 block.txs[i].tails.Count);
end;

{+}
function TBlockchain.size: LongWord;
begin
  Result := FblockChain.Count;
end;

{+/-}
function TBlockchain.validateBlock(block: TBlock): Boolean;
var
  i: LongWord;
  validated: Boolean;
  hash: TSecureVector;
  toRestore: TList<TPair<TOutput, LongWord>>;
begin
  BlockchainMutex->lock_shared();

  if bits <> block.bits then
    begin
      Result := False;
      Exit;
    end;

  if block.currentNumber <> blockChain.Count then
    begin
      Result := False;
      Exit;
    end;

  if (block.currentNumber <> 0) and
      (block.prevBlock <> SHA_256().process(blockChain.back.getBlockData)) then
    begin
      Result := False;
      Exit;
    end;

  if not validateMerkleRoot(block) then
    begin
      Result := False;
      Exit;
    end;

  hash := SHA_256().process(block.getBlockData);

  validated := True;

  // APronin - блок закомментирован в оригинале исходников
  // for (auto i = 0; i < bits; ++i) reuturn for hash checks
  // {
  // 	if (hash[i] != 0)
  // 		validated = false;
  // }

  if block.txs.Count > 0 then
    validated := validated and validateFirstTxn(block.txs[0])
  else
    validated := false;

  for i := 1 to block.txs.Count-1 do
    begin
      toRestore := TList<TPair<TOutput, LongWord>>.Create;

      validated := validated and validateTxn(block.txs[i], toRestore);

      if not validated then Break;
    end;

  BlockchainMutex->unlock_shared();

  if validated then
    begin
      BlockchainMutex->lock();

      setAvailibleTxes(block);
      clearAvailibleTxes;

      BlockchainMutex->unlock();
      clearNonValidated(block);
    end;

  Result := validated;
end;

{+}
function TBlockchain.validateBlockChain: Boolean;
var
  i: Integer;
  validated: Boolean;
begin
  validated := True;

  for i := 0 to FnonValidatedBlockChain.Count-1 do
    begin
      if validateBlock(FnonValidatedBlockChain[i]) then
        FblockChain.Add(FnonValidatedBlockChain[i])
      else
        begin
          FblockChain.Clear;
          FnonValidatedBlockChain.Clear;
          TTransaction.availibleTxes.Clear;
          validated := False;
          Break;
        end;
    end;

  FnonValidatedBlockChain.Clear;

  Result := validated;
end;

function TBlockchain.validateFirstTxn(txn: TTransaction): Boolean;
var
  validated: Boolean;
begin
  Result := False;

  validated := (txn.inputs.Count = 0) and (txn.tails.Count = 1);

  if validated then
    if txn.tails[0].getInfo.first = 100 then // HARDCODED
      Result := True;
end;

function TBlockchain.validateInputs(txn: TTransaction; toRestore: TList<TPair<TOutput, LongWord>>): LongWord;
begin

end;

function TBlockchain.validateMerkleRoot(block: TBlock): Boolean;
begin

end;

function TBlockchain.validateSignature(txn: TTransaction): Boolean;
begin

end;

function TBlockchain.validateTails(txn: TTransaction; sum: LongWord): Boolean;
begin

end;

function TBlockchain.validateTxn(txn: TTransaction;
  toRestore: TList<TPair<TOutput, LongWord>>): Boolean;
begin

end;

end.

