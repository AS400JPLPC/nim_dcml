# Decimal
# Copyright (c) 2018 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import dcml_lowlevel
import strformat
from strutils import Digits, parseInt

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

proc newDecimal*(): DecimalType =
  ## Initialize a empty DecimalType
  new result, deleteDecimal
  result[] = mpd_qnew()

proc newDecimal*(s: string): DecimalType =
  ## Create a new DecimalType from a string
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_string(result[], s, CTX_ADDR)

proc newDecimal*(s: int): DecimalType =
  ## Create a new DecimalType from an int
  new result, deleteDecimal
  result[] = mpd_qnew()
  when (sizeof(int) == 8):
    mpd_set_i64(result[], s, CTX_ADDR)
  else:
    mpd_set_i32(result[], s, CTX_ADDR)

proc newDecimal*(s: int64): DecimalType =
  ## Create a new DecimalType from a uint64
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_i64(result[], s, CTX_ADDR)

proc newDecimal*(s: int32): DecimalType =
  ## Create a new DecimalType from a uint32
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_i32(result[], s, CTX_ADDR)

proc newDecimal*(s: int8 or uint16): DecimalType =
  ## Create a new DecimalType from a int64
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_i32(result[], int32(s), CTX_ADDR)

proc newDecimal*(s: uint): DecimalType =
  ## Create a new DecimalType from an uint
  new result, deleteDecimal
  result[] = mpd_qnew()
  when (sizeof(uint) == 8):
    mpd_set_u64(result[], s, CTX_ADDR)
  else:
    mpd_set_u32(result[], s, CTX_ADDR)

proc newDecimal*(s: uint64): DecimalType =
  ## Create a new DecimalType from a uint64
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_u64(result[], s, CTX_ADDR)

proc newDecimal*(s: uint32): DecimalType =
  ## Create a new DecimalType from a uint32
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_u32(result[], s, CTX_ADDR)

proc newDecimal*(s: uint8 or uint16): DecimalType =
  ## Create a new DecimalType from a int64
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_u32(result[], uint32(s), CTX_ADDR)

proc newDecimal*(f: float ): DecimalType =
  ## Create a new DecimalType from a float
  ## probleme occurs tih overflow 
  var s: string = fmt"{f}"
  new result, deleteDecimal
  result[] = mpd_qnew()
  mpd_set_string(result[], s, CTX_ADDR)

proc clone*(b: DecimalType): DecimalType =
  ## Clone a DecimalType and returns a new independent one
  var status: uint32
  result = newDecimal()
  let success = mpd_qcopy(result[], b[], addr status)
  if success == 0:
    raise newException(DecimalError, "Decimal failed to copy")

# Operators


proc `+`*(a, b: DecimalType)=
  var status: uint32
  var r = newDecimal()
  mpd_qadd(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `+`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a + newDecimal(b) 

proc `+=`*(a, b: DecimalType) =
  ## Inplace addition
  var status: uint32
  var r = newDecimal()
  mpd_qadd(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `+=`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a += newDecimal(b)



proc `-`*(a, b: DecimalType) =
  var status: uint32
  var r = newDecimal()
  mpd_qsub(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `-`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a - newDecimal(b)


proc `-=`*(a, b: DecimalType) =
  ## Inplace subtraction
  var status: uint32
  var r = newDecimal()
  mpd_qsub(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `-=`*[T: SomeNumber](a: DecimalType, b: T) =
  a -= newDecimal(b)


proc `*`*(a, b: DecimalType)=
  var status: uint32
  var r = newDecimal()
  mpd_qmul(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `*`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a * newDecimal(b)

proc `*=`*(a, b: DecimalType) =
  ## Inplace multiplication
  var status: uint32
  var r = newDecimal()
  mpd_qmul(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `*=`*[T: SomeNumber](a: DecimalType, b: T) =
  a *= newDecimal(b)



proc `/`*(a, b: DecimalType) =
  var status: uint32
  var r = newDecimal()
  mpd_qdiv(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `/`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a / newDecimal(b)

proc `/=`*(a, b: DecimalType) =
  ## Inplace division
  var status: uint32
  var r = newDecimal()
  mpd_qdiv(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `/=`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a /= newDecimal(b)


proc `//`*(a, b: DecimalType)=
  ## Integer division, same as divint
  var status: uint32
  var r = newDecimal()
  mpd_qdivint(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `//`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a // newDecimal(b)

proc `^`*(a, b: DecimalType) =
  ## Power operator
  var status: uint32
  var r = newDecimal()
  mpd_qpow(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


template `^`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a ^ newDecimal(b)









## comparaison

proc `==`*(a, b: DecimalType): bool =
  var status: uint32
  let cmp = mpd_qcmp(a[], b[], addr status)
  if cmp == 0:
    return true
  else:
    return false

template `==`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a == newDecimal(b)

template `==`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  newDecimal(a) == b



proc `<`*(a, b: DecimalType): bool =
  var status: uint32
  let cmp = mpd_qcmp(a[], b[], addr status)
  if cmp == -1:
    return true
  else:
    return false

template `<`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a < newDecimal(b)
template `<`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  newDecimal(a) < b
  
proc `<=`*(a, b: DecimalType): bool =
  let less_cmp = a < b
  if less_cmp: return true
  let equal_cmp = a == b
  if equal_cmp: return true
  return false
template `<=`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a <= newDecimal(b)
template `<=`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  newDecimal(a) <= b




proc `>`*(a, b: DecimalType): bool =
  var status: uint32
  let cmp = mpd_qcmp(a[], b[], addr status)
  if cmp == 1:
    return true
  else:
    return false

template `>`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a > newDecimal(b)
template `>`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  newDecimal(a) > b
  
proc `>=`*(a, b: DecimalType): bool =
  let less_cmp = a > b
  if less_cmp: return true
  let equal_cmp = a == b
  if equal_cmp: return true
  return false
template `>=`*[T: SomeNumber](a: DecimalType, b: T): untyped =
  a >= newDecimal(b)
template `>=`*[T: SomeNumber](a: T, b: DecimalType): untyped =
  newDecimal(a) >= b















##----------------------------------------------------------------------------
## fonction avec decimal libre  
## Math functions
##----------------------------------------------------------------------------

proc divint*(a, b: DecimalType) =
  ## Integer division, same ass //
  var status: uint32
  var r = newDecimal()
  mpd_qdivint(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


proc rem*(a, b: DecimalType) =
  ## Returns the remainder of the division a/b
  var status: uint32
  var r = newDecimal()
  mpd_qrem(r[], a[], b[], CTX_ADDR, addr status)
  a.copyData(r)


proc fma*(a, b, c: DecimalType) =
  ## Fused multiplication-addition, returns a * b + c
  var status: uint32
  var r = newDecimal()
  mpd_qfma(r[], a[], b[], c[], CTX_ADDR, addr status)
  a.copyData(r)




# Math functions

proc `-`*(a: DecimalType) =
  ## Negation operator
  var status: uint32
  var r = newDecimal()
  mpd_qminus(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc plus*(a: DecimalType) =
  var status: uint32
  var r = newDecimal()
  mpd_qplus(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc abs*(a: DecimalType) =
  ## Absolute value
  var status: uint32
  var r = newDecimal()
  mpd_qabs(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)





proc reduce*(a: DecimalType) =
  ## If a is finite after applying rounding and overflow/underflow checks, result is set to the simplest form of a with all trailing zeros removed
  var status: uint32
  var r = newDecimal()
  mpd_qreduce(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc floor*(a: DecimalType) =
  ## Return the nearest integer towards -infinity
  var status: uint32
  var r = newDecimal()
  mpd_qfloor(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc ceil*(a: DecimalType) =
  ## Return the nearest integer towards +infinity
  var status: uint32
  var r = newDecimal()
  mpd_qceil(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc truncate*(a: DecimalType) =
  ## Return the truncated value of a
  var status: uint32
  var r = newDecimal()
  mpd_qtrunc(r[], a[], CTX_ADDR, addr status)
  a.copyData(r)


proc finalize*(a: DecimalType) =
  ## Apply the current context to a
  var status: uint32
  mpd_qfinalize(a[], CTX_ADDR, addr status)



#@@@@@@@@@@@@@@@@@@
#----------------------------------------------------
# BORNAGE POUR LA GESTION compta : stock etc....
# arrivé decimal SQL  FromString 
#----------------------------------------------------

proc fromString*(a: DecimalType;  pVal: string )  =
  ## set value from a string
  var sVal :string  = pval
  if (sVal == ""):  sVal="0"
  mpd_set_string(a[], sVal, CTX_ADDR)


proc copyData*(a, b: DecimalType)=
  var status: uint32
  mpd_copy_data(a[],b[],addr status)

proc newDcml*( iEntier: uint8 ; iScale : uint8 ): DecimalType =
  ## Initialize a empty DecimalType

  if iEntier + iScale  > cMaxDigit :
    raise newException(DecimalError, "Entier + Scale > cMaxDigit")
  else :
    var i:int = parseInt(fmt"{cMaxDigit}")
    setPrec(i)
    new result, deleteDecimal
    result[] = mpd_qnew()
    result.fromString("0")
    result.entier = iEntier
    result.scale  = iScale



proc defDcml*( a: DecimalType ; iEntier: uint8 ; iScale : uint8 ) =
  ## Initialize a empty DecimalType
  
  if iEntier + iScale  > cMaxDigit :
    raise newException(DecimalError, "Entier + Scale > cMaxDigit")
  else :
    a.entier = iEntier
    a.scale  = iScale

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
  var x= newDecimal()
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
  ## contrôle dépassement capacité

  CTX_CTRL = CTX_ADDR 
  CTX_CTRL.round = MPD_ROUND_05UP

  var iScale:int = int(a.scale)
  var iMax:int = int(a.entier + a.scale)
  var sNumber:string
  var i:int

  if (a.entier + a.scale) > cMaxDigit :
    return true
  
  sNumber= $a

  i = sNumber.len

  if sNumber.find('.') > -1 :
    i-= 1

  if '-' == sNumber[0] :
    i-= 1
  elif '+' == sNumber[0] :
    i-= 1
  elif 1 == mpd_iszero(a[]) :
    i = 0

  if i > iMax :
    return true
  else : 
    return false


#---------------------------------------
# contrôle &  validité PAS D'ARRONDI 
# formatage 
# maximun 38 digits
#---------------------------------------

proc Valide*(a: DecimalType) =
  # controle dépassement capacité
  if (a.entier + a.scale) > cMaxDigit :
    raise newException(DecimalError, "Overlay Digit 38 max")

  CTX_CTRL = CTX_ADDR 
  CTX_CTRL.round = MPD_ROUND_05UP

  var iEntier:int = int(a.entier)

  var iScale:int = int(a.scale)

  var sEntier:string

  var i:int 

  var x= newDecimal($a)

  # control partie entiere

  x.floor()

  sEntier= $x
  
  i = sEntier.len

  if '-' == sEntier[0] or '+' == sEntier[0] :
    i-= 1
  elif 1 == mpd_iszero(x[]) :
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
      x.fromString(sEntier)
    else :
      x.copyData(a)
      for i in 1..iScale :
        x *= 10
      x.truncate()
      for i in 1..iScale :
        x /= 10
  a.copyData(x)
#@@@@@@@@@@@@@@@@@@
