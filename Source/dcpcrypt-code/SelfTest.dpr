program SelfTest;
{$apptype console}

uses
  SysUtils,
  Classes,
  DCPbase64 in 'Source\DCPbase64.pas',
  DCPblockciphers in 'Source\DCPblockciphers.pas',
  DCPconst in 'Source\DCPconst.pas',
  DCPcrypt2 in 'Source\DCPcrypt2.pas',
  DCPblowfish in 'Source\Ciphers\DCPblowfish.pas',
  DCPcast128 in 'Source\Ciphers\DCPcast128.pas',
  DCPcast256 in 'Source\Ciphers\DCPcast256.pas',
  DCPdes in 'Source\Ciphers\DCPdes.pas',
  DCPgost in 'Source\Ciphers\DCPgost.pas',
  DCPice in 'Source\Ciphers\DCPice.pas',
  DCPidea in 'Source\Ciphers\DCPidea.pas',
  DCPmars in 'Source\Ciphers\DCPmars.pas',
  DCPmisty1 in 'Source\Ciphers\DCPmisty1.pas',
  DCPrc2 in 'Source\Ciphers\DCPrc2.pas',
  DCPrc4 in 'Source\Ciphers\DCPrc4.pas',
  DCPrc5 in 'Source\Ciphers\DCPrc5.pas',
  DCPrc6 in 'Source\Ciphers\DCPrc6.pas',
  DCPrijndael in 'Source\Ciphers\DCPrijndael.pas',
  DCPtea in 'Source\Ciphers\DCPtea.pas',
  DCPtwofish in 'Source\Ciphers\DCPtwofish.pas',
  DCPhaval in 'Source\Hashes\DCPhaval.pas',
  DCPmd4 in 'Source\Hashes\DCPmd4.pas',
  DCPmd5 in 'Source\Hashes\DCPmd5.pas',
  DCPripemd128 in 'Source\Hashes\DCPripemd128.pas',
  DCPripemd160 in 'Source\Hashes\DCPripemd160.pas',
  DCPsha1 in 'Source\Hashes\DCPsha1.pas',
  DCPtiger in 'Source\Hashes\DCPtiger.pas',
  DCPreg in 'Source\DCPreg.pas',
  DCPserpent in 'Source\Ciphers\DCPserpent.pas',
  DCPsha256 in 'Source\Hashes\DCPsha256.pas',
  DCPsha512 in 'Source\Hashes\DCPsha512.pas',
  DCPtypes in 'Source\DCPtypes.pas';

type
  TDCPHashClass = class of TDCP_hash;
  TDCPCipherClass = class of TDCP_cipher;

procedure TestHash(HashClass: TDCPHashClass);
begin
  if not HashClass.SelfTest then
    Writeln(Format('Self-test failed: %s', [HashClass.GetAlgorithm]));
end;

procedure TestCipher(CipherClass: TDCPCipherClass);
begin
  if not CipherClass.SelfTest then
    Writeln(Format('Self-test failed: %s', [CipherClass.GetAlgorithm]));
end;

begin
  TestHash(TDCP_haval);
  TestHash(TDCP_md4);
  TestHash(TDCP_md5);
  TestHash(TDCP_ripemd128);
  TestHash(TDCP_ripemd160);
  TestHash(TDCP_sha1);
  TestHash(TDCP_sha256);
  TestHash(TDCP_sha384);
  TestHash(TDCP_sha512);
  TestHash(TDCP_tiger);
  TestCipher(TDCP_blowfish);
  TestCipher(TDCP_cast128);
  TestCipher(TDCP_cast256);
  TestCipher(TDCP_des);
  TestCipher(TDCP_3des);
  TestCipher(TDCP_gost);
  TestCipher(TDCP_ice);
  TestCipher(TDCP_thinice);
  TestCipher(TDCP_ice2);
  TestCipher(TDCP_idea);
  TestCipher(TDCP_mars);
  TestCipher(TDCP_misty1);
  TestCipher(TDCP_rc2);
  TestCipher(TDCP_rc4);
  TestCipher(TDCP_rc5);
  TestCipher(TDCP_rc6);
  TestCipher(TDCP_rijndael);
  TestCipher(TDCP_serpent);
  TestCipher(TDCP_tea);
  TestCipher(TDCP_twofish);
  Writeln('Done.');
end.
