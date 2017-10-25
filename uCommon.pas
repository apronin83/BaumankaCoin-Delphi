unit uCommon;

interface

uses
  System.SysUtils, Generics.Collections;

type
  TVector8 = class(TList<Byte>)
  public
    function Equal(AVector8: TVector8): Boolean;
    function ToHex: String;
  end;

  TSecureVector = class(TVector8)
  end;

  TVectorOfSecureVector = class(TList<TSecureVector>)
  end;

  procedure InitVector(AVector: TVector8; ACount: Integer; AInitValue: Byte);
  procedure converter32to8(AFrom: LongWord; ATo: TVector8);
  function converter8to32(AData: TVector8; APosition: LongWord): LongWord;
  function hex_encode(AData: TVector8): String;

implementation

{ TSecureVector }

function TVector8.Equal(AVector8: TVector8): Boolean;
begin
  { TODO : Написать алгоритм сравнения }
end;

function TVector8.ToHex: String;
begin
  { TODO : Написать алгоритм преобразования в HEX }
  Result := 'HEX VALUE';
end;

procedure InitVector(AVector: TVector8; ACount: Integer; AInitValue: Byte);
var
  i: Integer;
begin
  for i := 0 to ACount do

end;

procedure converter32to8(AFrom: LongWord; ATo: TVector8);
var
  i: Integer;
  FromBuff: array[0..3] of Byte absolute AFrom;
begin
  for i := 0 to 3 do
    ATo.Add(FromBuff[i]);
end;

function converter8to32(AData: TVector8; APosition: LongWord): LongWord;
var
  i: Integer;
  ResultBuff: array[0..3] of Byte;
  pResult: PLongWord;
begin
  for i := 0 to 3 do
    ResultBuff[i] := AData[APosition + i];

  Inc(APosition, 4); // Сдвигаем позицию чтения

  pResult := @ResultBuff[0];

  Result := LongWord(pResult^);
end;

function ByteToHex(AInByte: Byte): String;
const
  Digits: array[0..15] of Char = '0123456789ABCDEF';
begin
  Result := Digits[AInByte shr 4] + Digits[AInByte and $0F];
end;

function hex_encode(AData: TVector8): String;
var
  i: Integer;
begin
  Result := '';

  for i := 0 to AData.Count-1 do
    Result := Result + ByteToHex(AData[i]);
end;

end.
