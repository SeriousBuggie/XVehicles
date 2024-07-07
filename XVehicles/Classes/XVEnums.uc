//=============================================================================
// XVEnums.
//=============================================================================
class XVEnums expands Info;

enum E4
{
	E4_V0,
	E4_V1,
	E4_V2,
	E4_V3
};
var const E4 IntToE4Table[4];

enum E28
{
	E28_V0,
	E28_V1,
	E28_V2,
	E28_V3,
	E28_V4,
	E28_V5,
	E28_V6,
	E28_V7,
	E28_V8,
	E28_V9,
	E28_V10,
	E28_V11,
	E28_V12,
	E28_V13,
	E28_V14,
	E28_V15,
	E28_V16,
	E28_V17,
	E28_V18,
	E28_V19,
	E28_V20,
	E28_V21,
	E28_V22,
	E28_V23,
	E28_V24,
	E28_V25,
	E28_V26,
	E28_V27,
};
var const E28 IntToE28Table[28];

static final function E4 IntToE4(int i)
{
	return default.IntToE4Table[i];
}

static final function E28 IntToE28(int i)
{
	return default.IntToE28Table[i];
}

defaultproperties
{
	IntToE4Table(1)=E4_V1
	IntToE4Table(2)=E4_V2
	IntToE4Table(3)=E4_V3
	IntToE28Table(1)=E28_V1
	IntToE28Table(2)=E28_V2
	IntToE28Table(3)=E28_V3
	IntToE28Table(4)=E28_V4
	IntToE28Table(5)=E28_V5
	IntToE28Table(6)=E28_V6
	IntToE28Table(7)=E28_V7
	IntToE28Table(8)=E28_V8
	IntToE28Table(9)=E28_V9
	IntToE28Table(10)=E28_V10
	IntToE28Table(11)=E28_V11
	IntToE28Table(12)=E28_V12
	IntToE28Table(13)=E28_V13
	IntToE28Table(14)=E28_V14
	IntToE28Table(15)=E28_V15
	IntToE28Table(16)=E28_V16
	IntToE28Table(17)=E28_V17
	IntToE28Table(18)=E28_V18
	IntToE28Table(19)=E28_V19
	IntToE28Table(20)=E28_V20
	IntToE28Table(21)=E28_V21
	IntToE28Table(22)=E28_V22
	IntToE28Table(23)=E28_V23
	IntToE28Table(24)=E28_V24
	IntToE28Table(25)=E28_V25
	IntToE28Table(26)=E28_V26
	IntToE28Table(27)=E28_V27
}
