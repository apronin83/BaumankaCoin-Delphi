unit uTail;

interface

uses
  System.SysUtils, Generics.Collections, Vcl.StdCtrls,
  uCommon;

type
  TTail = class(TObject)
  private
    FOutputControl: TMemo;
  private
    intValue: LongWord; //size_t = 0;
    address: TSecureVector;
    function scan(data: TVector8; position: LongWord): Boolean; //Botan::secure_vector<uint8_t> address = Botan::secure_vector<uint8_t>(32, 0);
  public
    constructor Create(v_integer: LongWord; destination: TSecureVector);

    function getInfo: TPair<LongWord, TSecureVector>;

    function Equal(ATail: TTail): Boolean;

    function setValue(v_integer: LongWord): Boolean;

    function setAddress(destination: TSecureVector): Boolean;

    procedure converter(from: LongWord; v_to: TVector8);

    function convertTo8: TVector8;

    function OutputMethod(ATail: TTail): String;
  end;

implementation

{ TTail }

constructor TTail.Create(v_integer: LongWord; destination: TSecureVector);
begin
  intValue := 0;

  address := TSecureVector.Create;

  InitVector(address, 32, 0); //Botan::secure_vector<uint8_t> address = Botan::secure_vector<uint8_t>(32, 0);

  address := destination;
end;

function TTail.Equal(ATail: TTail): Boolean;
begin
  Result := address.Equal(ATail.address) and (intValue = ATail.intValue);
end;

function TTail.getInfo: TPair<LongWord, TSecureVector>;
begin
  Result := TPair<LongWord, TSecureVector>.Create(intValue, address);
end;

function TTail.setValue(v_integer: LongWord): Boolean;
begin
  intValue := v_integer;
  Result := True;
end;

function TTail.setAddress(destination: TSecureVector): Boolean;
begin
  // assert(destination.size() != 256);//check this assert, size can be
  // different (257 if /0) or in different encoding that make size biiger or
  // smaller and then change to throw exception
  address := destination;

  Result := True;
end;

procedure TTail.converter(from: LongWord; v_to: TVector8);
begin
  converter32to8(from, v_to);
end;

function TTail.convertTo8: TVector8;
var
  v_to: TVector8;
  i: Integer;
begin
  v_to := TVector8.Create;

  converter(intValue, v_to);

  for i := 0 to address.Count-1 do
    v_to.Add(address[i]);

  Result := v_to;
end;

function TTail.scan(data: TVector8; position: LongWord): Boolean;
var
  i: Integer;
begin
  intValue := converter8to32(data, position);

  address.Clear;

  for i := 0 to 31 do
    begin
      address.Add(data[position]);
      Inc(position);
    end;

  Result := True;
end;

function TTail.OutputMethod(ATail: TTail): String;
begin
  Result := 'Tail ' + #13#10 +
            IntToStr(ATail.intValue) + #13#10 +
            'Address: ' + hex_encode(ATail.address);
end;

end.
