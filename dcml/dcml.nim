# Decimal
# Copyright (c) 2018 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import dcml_lowlevel
import strformat
from strutils import Digits, parseInt,replace , repeat , isDigit

type
  DecimalType* = ref[ptr mpd_t]
  DecimalError* = object of Exception

const
  DEFAULT_PREC = MPD_RDIGITS * 2
  DEFAULT_EMAX = when (sizeof(int) == 8): 999999999999999999 else: 425000000
  DEFAULT_EMIN = when (sizeof(int) == 8): -999999999999999999 else: -425000000



var CTX: mpd_context_t
var CTX_ADDR = addr CTX
mpd_defaultcontext(CTX_ADDR)

#@@@@@@@@@@@@@@@@@@
#------------------
let cMaxDigit : uint8 = 38
#------------------
var CTX_CTRL = addr CTX

proc copyData*(a, b: DecimalType)
#@@@@@@@@@@@@@@@@@@

proc setPrec*(prec: mpd_ssize_t) =
  ## Sets the precision (number of decimals) in the Context
  if 0 < prec:
    let success = mpd_qsetprec(CTX_ADDR, prec)
    if success == 0:
      raise newException(DecimalError, "Couldn't set precision")


proc `$`*(s: DecimalType): string =
  ## Convert DecimalType to string
  $mpd_to_sci(s[], 0)

proc deleteDecimal(x: DecimalType) =
  if not x.isNil:          # Managed by Nim
    assert(not(x[].isNil)) # Managed by MpDecimal
    mpd_del(x[])

proc InterneNewDecimalReserved*(): DecimalType =
  ## Initialize a empty DecimalType
  new result, deleteDecimal
  result[] = mpd_qnew()

proc InterneNewDecimalReserved*(s: string): DecimalType =
  ## Create a new DecimalType from a string
  var sVal:string = s
  #correction valeur par defaut
  if (sVal == "") :  sVal="0"
  sVal = sVal.replace("+","" )
  sVal = sVal.replace("-","" )
  sVal = sVal.replace(".","" )
  if sVal.isDigit() == false  or s == ".":  
    raise newException(DecimalError, "Decimal failed to InterneNewDecimalReserved(String)")

  sVal =s
  if (sVal == "") :  sVal="0"
  elif sVal[0] == '.' and len(sVal) > 1: sVal = fmt"0{sval}"

  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_string(result[], sVal, CTX_ADDR)



proc InterneNewDecimalReserved*(s: int): DecimalType =
  ## Create a new DecimalType from an int
  new result, deleteDecimal
  result[] = mpd_qnew()
  when (sizeof(int) == 8):
    mpd_set_i64(result[], s, CTX_ADDR)
  else:
    mpd_set_i32(result[], s, CTX_ADDR)

proc InterneNewDecimalReserved*(s: int64): DecimalType =
  ## Create a new DecimalType from a uint64
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_i64(result[], s, CTX_ADDR)

proc InterneNewDecimalReserved*(s: int32): DecimalType =
  ## Create a new DecimalType from a uint32
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_i32(result[], s, CTX_ADDR)

proc InterneNewDecimalReserved*(s: int8 or uint16): DecimalType =
  ## Create a new DecimalType from a int64
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_i32(result[], int32(s), CTX_ADDR)

proc InterneNewDecimalReserved*(s: uint): DecimalType =
  ## Create a new DecimalType from an uint
  new result, deleteDecimal
  result[] = mpd_qnew()
  when (sizeof(uint) == 8):
    mpd_set_u64(result[], s, CTX_ADDR)
  else:
    mpd_set_u32(result[], s, CTX_ADDR)

proc InterneNewDecimalReserved*(s: uint64): DecimalType =
  ## Create a new DecimalType from a uint64
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_u64(result[], s, CTX_ADDR)

proc InterneNewDecimalReserved*(s: uint32): DecimalType =
  ## Create a new DecimalType from a uint32
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_u32(result[], s, CTX_ADDR)

proc InterneNewDecimalReserved*(s: uint8 or uint16): DecimalType =
  ## Create a new DecimalType from a int64
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_u32(result[], uint32(s), CTX_ADDR)

proc InterneNewDecimalReserved*(f: float ): DecimalType =
  ## Create a new DecimalType from a float
  ## probleme occurs tih overflow 
  var s: string = fmt"{f}"
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_string(result[], s, CTX_ADDR)

proc clone*(b: DecimalType): DecimalType =
  ## Clone a DecimalType and returns a new independent one
  var status: uint32
  result = InterneNewDecimalReserved()
  let success = mpd_qcopy(result[], b[], addr status)
  if success == 0:
    raise newException(DecimalError, "Decimal failed to copy")

# Operators


proc `+`*(a, b: DecimalType)=
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qadd(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `+`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a + InterneNewDecimalReserved(b) 

proc `+=`*(a, b: DecimalType) =
  ## Inplace addition
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qadd(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `+=`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a += InterneNewDecimalReserved(b)



proc `-`*(a, b: DecimalType) =
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qsub(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `-`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a - InterneNewDecimalReserved(b)


proc `-=`*(a, b: DecimalType) =
  ## Inplace subtraction
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qsub(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `-=`*[T: SomeNumber](a: DecimalType, b: T) =
  a -= InterneNewDecimalReserved(b)


proc `*`*(a, b: DecimalType)=
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qmul(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `*`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a * InterneNewDecimalReserved(b)

proc `*=`*(a, b: DecimalType) =
  ## Inplace multiplication
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qmul(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `*=`*[T: SomeNumber](a: DecimalType, b: T) =
  a *= InterneNewDecimalReserved(b)



proc `/`*(a, b: DecimalType) =
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qdiv(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `/`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a / InterneNewDecimalReserved(b)

proc `/=`*(a, b: DecimalType) =
  ## Inplace division
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qdiv(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `/=`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a /= InterneNewDecimalReserved(b)


proc `//`*(a, b: DecimalType)=
  ## Integer division, same as divint
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qdivint(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `//`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a // InterneNewDecimalReserved(b)

proc `^`*(a, b: DecimalType) =
  ## Power operator
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qpow(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `^`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a ^ InterneNewDecimalReserved(b)









## comparaison

proc `==`*(a, b: DecimalType): bool =
  var status: uint32
  let cmp = mpd_qcmp(a[], b[], addr status)
  if cmp == 0:
    return true
  else:
    return false

template `==`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a == InterneNewDecimalReserved(b)

template `==`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  InterneNewDecimalReserved(a) == b



proc `<`*(a, b: DecimalType): bool =
  var status: uint32
  let cmp = mpd_qcmp(a[], b[], addr status)
  if cmp == -1:
    return true
  else:
    return false

template `<`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a < InterneNewDecimalReserved(b)
template `<`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  InterneNewDecimalReserved(a) < b
  
proc `<=`*(a, b: DecimalType): bool =
  let less_cmp = a < b
  if less_cmp: return true
  let equal_cmp = a == b
  if equal_cmp: return true
  return false
template `<=`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a <= InterneNewDecimalReserved(b)
template `<=`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  InterneNewDecimalReserved(a) <= b




proc `>`*(a, b: DecimalType): bool =
  var status: uint32
  let cmp = mpd_qcmp(a[], b[], addr status)
  if cmp == 1:
    return true
  else:
    return false

template `>`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a > InterneNewDecimalReserved(b)
template `>`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  InterneNewDecimalReserved(a) > b
  
proc `>=`*(a, b: DecimalType): bool =
  let less_cmp = a > b
  if less_cmp: return true
  let equal_cmp = a == b
  if equal_cmp: return true
  return false
template `>=`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a >= InterneNewDecimalReserved(b)
template `>=`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  InterneNewDecimalReserved(a) >= b















##----------------------------------------------------------------------------
## fonction avec decimal libre  
## Math functions
##----------------------------------------------------------------------------

proc divint*(a, b: DecimalType) =
  ## Integer division, same ass //
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qdivint(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


proc rem*(a, b: DecimalType) =
  ## Returns the remainder of the division a/b
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qrem(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


proc fma*(a, b, c: DecimalType) =
  ## Fused multiplication-addition, returns a * b + c
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qfma(r[], a[], b[], c[], CTX_ADDR, addr status)
  a.copyData(r)




# Math functions

proc `-`*(a: DecimalType) =
  ## Negation operator
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qminus(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc plus*(a: DecimalType) =
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qplus(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc abs*(a: DecimalType) =
  ## Absolute value
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qabs(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc floor*(a: DecimalType) =
  ## Return the nearest integer towards -infinity
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qfloor(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc ceil*(a: DecimalType) =
  ## Return the nearest integer towards +infinity
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qceil(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc truncate*(a: DecimalType) =
  ## Return the truncated value of a
  var status: uint32
  var r = InterneNewDecimalReserved()
  mpd_qtrunc(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc finalize*(a: DecimalType) =
  ## Apply the current context to a
  var status: uint32
  mpd_qfinalize(a[], CTX_ADDR, addr status)



#@@@@@@@@@@@@@@@@@@
#----------------------------------------------------
# BORNAGE POUR LA GESTION compta : stock etc....
# arrivé decimal SQL  frmStr 
#----------------------------------------------------

proc frmStr*(a: DecimalType;  pVal: string )  =
  ## set value from a string
  var sVal :string

  #correction valeur par defaut
  sVal = pVal
  if (sVal == "") :  sVal="0"
  sVal = sVal.replace("+","" )
  sVal = sVal.replace("-","" )
  sVal = sVal.replace(".","" )
  if sVal.isDigit() == false  or pVal == ".":  
    raise newException(DecimalError, "Decimal failed to frmStr")
  sVal =pVal
  if (sVal == "") :  sVal="0"
  elif sVal[0] == '.' and len(sVal) > 1: sVal = fmt"0{sval}"

  mpd_set_string(a[], sVal, CTX_ADDR)


proc copyData*(a, b: DecimalType)=
  var status: uint32
  mpd_copy_data(a[],b[],addr status)




proc newDcml*( iEntier: uint8 ; iScale : uint8 ): DecimalType =
  ## Initialize a empty DecimalType

  if iEntier + iScale  > cMaxDigit or ( iEntier == 0 and iScale == 0 ):
    raise newException(DecimalError, "Failed Init")

  var i:int = parseInt(fmt"{cMaxDigit}")
  setPrec(i)
  new result, deleteDecimal
  result[] = mpd_qnew()
  result.frmStr("0")
  result.entier = iEntier
  result.scale  = iScale


proc delDcml*(a: DecimalType) =
  mpd_del(a[])
#---------------------------------------
# ARRONDI comptable / commercial   
# 5 => + 1   sinon trunc  
# maximun 38 digits 
#---------------------------------------

proc aRound*(a: DecimalType; iScale:int )=
  var status: uint32
  CTX_CTRL = CTX_ADDR 
  CTX_CTRL.round = MPD_ROUND_HALF_UP

  var i:int
  var x= InterneNewDecimalReserved()
  x.copyData(a)

  if iScale > 0 :
    
    for i in 1..iScale :
      x*=10
    mpd_qround_to_intx(x[], x[], CTX_ADDR, addr status)
    for i in 1..iScale :
      x /= 10

  else:
    x.floor()

  a.copyData(x)





#---------------------------------------
# contrôle len buffer and caractéristique  
# maximun 38 digits
#---------------------------------------

proc isErr*(a: DecimalType):bool =
  if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
    raise newException(DecimalError, "Failed Init")
  ## contrôle dépassement capacité

  CTX_CTRL = CTX_ADDR 
  CTX_CTRL.round = MPD_ROUND_05UP

  var iEntier:int = int(a.entier)
  var iScale:int = int(a.scale)
  var sNumber:string = $a
  var iMax:int =  iEntier + iScale
  var iLen:int =  sNumber.len()

  if iEntier == 0 : 
    iMax = iMax + 1
    iLen = iLen - 1
  if sNumber.find('-') > -1 : 
    iMax = iMax - 1
    iLen = iLen - 1 
  if sNumber.find('+') > -1 :
    iMax = iMax - 1
    iLen = iLen - 1
  if sNumber.find('.') > -1 :
    iMax = iMax - 1
    iLen = iLen - 1


  if iMax > int(cMaxDigit)  or iMax < iLen:
    return true
  else : 
    return false


#---------------------------------------
# formatage 
# alustement rigth zeros
#---------------------------------------
proc ajustRzeros*(a: DecimalType)=
  if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
    raise newException(DecimalError, "Failed Init")
  let padding = '0'

  var iScale:int = int(a.scale)
  var sNumber:string = $a
  var iLen: int = sNumber.len()
  var iPos: int = sNumber.find('.')

  if iPos >= 0 : iPos += int(1)
  # nombre de digit manquant
  iLen -= iPos

  if iLen < iScale :
    sNumber.add(padding.repeat(iLen))

  a.frmStr(sNumber)



#---------------------------------------
# contrôle &  validité PAS D'ARRONDI 
# formatage 
# maximun 38 digits
#---------------------------------------

proc Valide*(a: DecimalType) =
  # controle dépassement capacité
  if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
    raise newException(DecimalError, "Failed Init")

  CTX_CTRL = CTX_ADDR 
  CTX_CTRL.round = MPD_ROUND_05UP



  var iEntier:int = int(a.entier)

  var iScale:int = int(a.scale)

  var sEntier:string

  var i , d :int 
  var x= InterneNewDecimalReserved($a)
  
  # control partie entiere

  x.floor()

  sEntier= $x
  sEntier = sEntier.replace("+","" )
  sEntier = sEntier.replace("-","" )
  i = sEntier.len

  # dcml(0.x) on ne compte pas si 0 entier
  if i == 1 and  sEntier[0] == '0':
    i = 0

  if i > iEntier :
    raise newException(DecimalError, "Overlay Digit") 

  # formatages 
  # suppression des digits scale en trop  
  # printf .00 etc...

  if iScale != 0 :
    if x == a :
      sEntier= fmt"{sEntier}."
      for i in 1..iScale :
        sEntier = fmt"{sEntier}0"
      x.frmStr(sEntier)
    else :
      x.copyData(a)
      for i in 1..iScale :
        x *= 10
      x.truncate()
      for i in 1..iScale :
        x /= 10
  
  a.copyData(x)
  a.ajustRzeros()
#@@@@@@@@@@@@@@@@@@
