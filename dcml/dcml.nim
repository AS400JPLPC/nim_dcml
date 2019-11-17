# Decimal
# Copyright (c) 2018 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import dcml_lowlevel
import strformat
from strutils import Digits, parseInt,replace , repeat , isDigit ,formatFloat
import typeinfo



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


proc deleteDecimal(x: DecimalType) =
  if not x.isNil:          # Managed by Nim
    assert(not(x[].isNil)) # Managed by MpDecimal
    mpd_del(x[])


proc `$`*(a: DecimalType): string =
  ## Convert DecimalType to string natural of basic mpd
  $mpd_to_sci(a[], 0)

proc signed*(a: DecimalType): string =
  ## Convert DecimalType to string force signed '+'
  var s: string = $mpd_to_sci(a[], 0)
  
  if s[0].isDigit == true : return fmt"+{s}"
  else: return fmt"{s}"



proc setDcml*(a, b : DecimalType) =
  var status: uint32
  mpd_copy_data(a[],b[],addr status)


template setDcml*[T: SomeNumber](a: DecimalType, x: T) =
  var n = x
  var b:DecimalType
  new b, deleteDecimal
  b[] = mpd_qnew()

  case kind(toAny(n)) :
    of akInt8 , akInt16 ,akInt32 :
      mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akInt64 :
      mpd_set_i64(b[], int64(x), CTX_ADDR)

    of akInt :
      when (sizeof(int(x)) == 8):
        mpd_set_i64(b[], int64(x), CTX_ADDR)
      else:
        mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akUInt8 , akUInt16 ,akUInt32 :
      mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akUInt64 :
      mpd_set_u64(b[], uint64(x), CTX_ADDR)

    of akUInt :
      when (sizeof(uint(x)) == 8):
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
      else:
        mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akFloat :
      var s: string = formatFloat(float(n)) 
      mpd_set_string(b[], s, CTX_ADDR)
      b.reduce()
  a.setDcml(b)

proc setDcml*(a : DecimalType, x:string) =
  var sVal:string = x
  #test par defaut
  if (sVal == "" or sVal=="0" ) :  
    sVal="0"
    sVal = sVal.replace("+","" )
    sVal = sVal.replace("-","" )
    sVal = sVal.replace(".","" )
    if sVal.isDigit() == false :  
      raise newException(DecimalError, "Decimal failed to newDecimal(String)")
  sVal = x
  mpd_set_string(a[], sVal, CTX_ADDR)



proc clone*(b: DecimalType): DecimalType =
  ## Clone a DecimalType and returns a new independent one
  var status: uint32
  var r:DecimalType
  new r, deleteDecimal
  r[] = mpd_qnew()
  let success = mpd_qcopy(r[], b[], addr status)
  if success == 0:
    raise newException(DecimalError, "Decimal failed to copy")
  r.entier = b.entier
  r.scale  = b.scale
  return r






# Operators

proc `+`*(a, b: DecimalType)=
  var status: uint32
  mpd_qadd(a[], a[], b[], CTX_ADDR, addr status)


template `+`*[T: SomeNumber](a: DecimalType, x: T) =
  ## ADD decimal from X
  var n = x

  var b:DecimalType
  new b, deleteDecimal
  b[] = mpd_qnew()

  case kind(toAny(n)) :
    of akInt8 , akInt16 ,akInt32 :
      mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akInt64 :
      mpd_set_i64(b[], int64(x), CTX_ADDR)

    of akInt :
      when (sizeof(int(x)) == 8):
        mpd_set_i64(b[], int64(x), CTX_ADDR)
      else:
        mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akUInt8 , akUInt16 ,akUInt32 :
      mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akUInt64 :
      mpd_set_u64(b[], uint64(x), CTX_ADDR)

    of akUInt :
      when (sizeof(uint(x)) == 8):
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
      else:
        mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akFloat :
      var s: string = formatFloat(float(n)) 
      mpd_set_string(b[], s, CTX_ADDR)
      b.reduce()
    else :
      raise newException(DecimalError, "Failed opération +")
  a + b





proc `-`*(a, b: DecimalType) =
  ## SUB decimal from X
  var status: uint32
  mpd_qsub(a[], a[], b[], CTX_ADDR, addr status)



template `-`*[T: SomeNumber](a: DecimalType, x: T)=
  var n = x

  var b:DecimalType
  new b, deleteDecimal
  b[] = mpd_qnew()

  case kind(toAny(n)) :
    of akInt8 , akInt16 ,akInt32 :
      mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akInt64 :
      mpd_set_i64(b[], int64(x), CTX_ADDR)

    of akInt :
      when (sizeof(int(x)) == 8):
        mpd_set_i64(b[], int64(x), CTX_ADDR)
      else:
        mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akUInt8 , akUInt16 ,akUInt32 :
      mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akUInt64 :
      mpd_set_u64(b[], uint64(x), CTX_ADDR)

    of akUInt :
      when (sizeof(uint(x)) == 8):
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
      else:
        mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akFloat :
      var s: string = formatFloat(float(n)) 
      mpd_set_string(b[], s, CTX_ADDR)
      b.reduce()
    else :
      raise newException(DecimalError, "Failed opération -")
  a - b





proc `*`*(a, b: DecimalType)=
  ## MULT decimal from X
  var status: uint32
  mpd_qmul(a[], a[], b[], CTX_ADDR, addr status)

template `*`*[T: SomeNumber](a: DecimalType, x: T) =
  var n = x

  var b:DecimalType
  new b, deleteDecimal
  b[] = mpd_qnew()

  case kind(toAny(n)) :
    of akInt8 , akInt16 ,akInt32 :
      mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akInt64 :
      mpd_set_i64(b[], int64(x), CTX_ADDR)

    of akInt :
      when (sizeof(int(x)) == 8):
        mpd_set_i64(b[], int64(x), CTX_ADDR)
      else:
        mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akUInt8 , akUInt16 ,akUInt32 :
      mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akUInt64 :
      mpd_set_u64(b[], uint64(x), CTX_ADDR)

    of akUInt :
      when (sizeof(uint(x)) == 8):
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
      else:
        mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akFloat :
      var s: string = formatFloat(float(n)) 
      mpd_set_string(b[], s, CTX_ADDR)
      b.reduce()
    else :
      raise newException(DecimalError, "Failed opération *")
  a * b





proc `/`*(a, b: DecimalType) =
  ## DIV decimal from X
  var status: uint32
  mpd_qdiv(a[], a[], b[], CTX_ADDR, addr status)

template `/`*[T: SomeNumber](a: DecimalType, x: T)=
  var n = x

  var b:DecimalType
  new b, deleteDecimal
  b[] = mpd_qnew()

  case kind(toAny(n)) :
    of akInt8 , akInt16 ,akInt32 :
      mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akInt64 :
      mpd_set_i64(b[], int64(x), CTX_ADDR)

    of akInt :
      when (sizeof(int(x)) == 8):
        mpd_set_i64(b[], int64(x), CTX_ADDR)
      else:
        mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akUInt8 , akUInt16 ,akUInt32 :
      mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akUInt64 :
      mpd_set_u64(b[], uint64(x), CTX_ADDR)

    of akUInt :
      when (sizeof(uint(x)) == 8):
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
      else:
        mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akFloat :
      var s: string = formatFloat(float(n)) 
      mpd_set_string(b[], s, CTX_ADDR)
      b.reduce()
    else :
      raise newException(DecimalError, "Failed opération /")
  a / b





proc `//`*(a, b: DecimalType)=
  ## DIVINTEGER  decimal from X
  var status: uint32
  mpd_qdivint(a[], a[], b[], CTX_ADDR, addr status)


template `//`*[T: SomeNumber](a: DecimalType, x: T)=
  var n = x

  var b:DecimalType
  new b, deleteDecimal
  b[] = mpd_qnew()

  case kind(toAny(n)) :
    of akInt8 , akInt16 ,akInt32 :
      mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akInt64 :
      mpd_set_i64(b[], int64(x), CTX_ADDR)

    of akInt :
      when (sizeof(int(x)) == 8):
        mpd_set_i64(b[], int64(x), CTX_ADDR)
      else:
        mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akUInt8 , akUInt16 ,akUInt32 :
      mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akUInt64 :
      mpd_set_u64(b[], uint64(x), CTX_ADDR)

    of akUInt :
      when (sizeof(uint(x)) == 8):
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
      else:
        mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akFloat :
      var s: string = formatFloat(float(n)) 
      mpd_set_string(b[], s, CTX_ADDR)
      b.reduce()
    else :
      raise newException(DecimalError, "Failed opération //")
  a // b





proc `^`*(a, b: DecimalType) =
  ## POWER   decimal from X
  var status: uint32
  mpd_qpow(a[], a[], b[], CTX_ADDR, addr status)


template `^`*[T: SomeNumber](a: DecimalType, x: T)=
  var n = x

  var b:DecimalType
  new b, deleteDecimal
  b[] = mpd_qnew()

  case kind(toAny(n)) :
    of akInt8 , akInt16 ,akInt32 :
      mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akInt64 :
      mpd_set_i64(b[], int64(x), CTX_ADDR)

    of akInt :
      when (sizeof(int(x)) == 8):
        mpd_set_i64(b[], int64(x), CTX_ADDR)
      else:
        mpd_set_i32(b[], int32(x), CTX_ADDR)

    of akUInt8 , akUInt16 ,akUInt32 :
      mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akUInt64 :
      mpd_set_u64(b[], uint64(x), CTX_ADDR)

    of akUInt :
      when (sizeof(uint(x)) == 8):
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
      else:
        mpd_set_u32(b[], uint32(x), CTX_ADDR)

    of akFloat :
      var s: string = formatFloat(float(n)) 
      mpd_set_string(b[], s, CTX_ADDR)
      b.reduce()
    else :
      raise newException(DecimalError, "Failed opération ^")
  a ^ b









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

proc divint*(r,a, b: DecimalType) =
  ## Integer division, same ass //
  var status: uint32
  mpd_qdivint(r[], a[], b[], CTX_ADDR, addr status)



proc rem*(r ,a, b: DecimalType) =
  ## Returns the remainder of the division a/b
  var status: uint32
  mpd_qrem(r[], a[], b[], CTX_ADDR, addr status)



proc fma*(r, a, b, c: DecimalType) =
  ## Fused multiplication-addition, returns a * b + c
  var status: uint32
  mpd_qfma(r[], a[], b[], c[], CTX_ADDR, addr status)




# Math functions

proc minus*(a: DecimalType) =
  ## Negation operator
  var status: uint32
  mpd_qminus(a[], a[], CTX_ADDR, addr status)



proc plus*(a: DecimalType) =
  var status: uint32
  mpd_qplus(a[], a[], CTX_ADDR, addr status)
  var sPlus:string = fmt"+{$a}"
  mpd_set_string(a[], sPlus, CTX_ADDR)




proc floor*(r,a: DecimalType) =
  ## Return the nearest integer towards -infinity
  var status: uint32
  mpd_qfloor(r[], a[], CTX_ADDR, addr status)



proc ceil*(r,a: DecimalType) =
  ## Return the nearest integer towards +infinity
  var status: uint32
  mpd_qceil(r[], a[], CTX_ADDR, addr status)


proc truncate*(a: DecimalType) =
  ## Return the truncated value of a
  var status: uint32
  mpd_qtrunc(a[], a[], CTX_ADDR, addr status)



proc finalize*(a: DecimalType) =
  ## Apply the current context to a
  var status: uint32
  mpd_qfinalize(a[], CTX_ADDR, addr status)


proc reduce*(a: DecimalType) =
  ## If a is finite after applying rounding and overflow/underflow checks,
  ## result is set to the simplest form of a with all trailing zeros removed
  var status: uint32
  mpd_qreduce(a[], a[], CTX_ADDR, addr status)

#---------------------------------------
# contrôle len buffer and caractéristique  
# maximun 38 digits
#---------------------------------------

proc isErr*(a: DecimalType):bool =
  if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
    raise newException(DecimalError, "Failed Init isErr")
  ## contrôle dépassement capacité

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
proc Rjust*(a: DecimalType)=
  if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
    raise newException(DecimalError, "Failed Init  Rjust")
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
  a.setDcml(sNumber)



#---------------------------------------
# contrôle &  validité PAS D'ARRONDI 
# formatage 
# maximun 38 digits
#---------------------------------------

proc Valide*(a: DecimalType) =
  ## controle dépassement capacité
  if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
    raise newException(DecimalError, "Failed Init Vaile()")
  var status: uint32
  var CTXN: mpd_context_t
  var CTX_CTRL = addr CTXN
  CTX_CTRL.round = MPD_ROUND_05UP


  var iEntier:int = int(a.entier)

  var iScale:int = int(a.scale)

  var sEntier:string

  var i , d :int 
  var r:DecimalType
  new r, deleteDecimal
  r[] = mpd_qnew()
  # control partie entiere

  r.floor(a)

  sEntier= $r
  sEntier = sEntier.replace("+","" )
  sEntier = sEntier.replace("-","" )
  i = sEntier.len

  # dcml(0.x) on ne compte pas si 0 entier
  if i == 1 and  sEntier[0] == '0':
    i = 0

  if i > iEntier :
    raise newException(DecimalError, fmt"Overlay Digit Valide() value:{a} ") 

  ## formatages 
  ## suppression des digits scale en trop  


  if iScale != 0 :
    if r == a :
      sEntier= fmt"{sEntier}."
      for i in 1..iScale :
        sEntier = fmt"{sEntier}0"
      r.setDcml(sEntier)
    else :
      mpd_copy_data(r[],a[],addr status)
      for i in 1..iScale :
        r*10
      r.truncate()
      for i in 1..iScale :
        r/10
  
  mpd_copy_data(a[],r[],addr status)
  a.Rjust()


#---------------------------------------
# ARRONDI comptable / commercial   
# 5 => + 1   sinon trunc  
# maximun 38 digits 
#---------------------------------------

proc Round*(a: DecimalType; iScale:int )=
  var status: uint32
  var CTXN: mpd_context_t
  var CTX_CTRL = addr CTXN
  CTX_CTRL.round = MPD_ROUND_05UP

  var i:int
  var r:DecimalType
  new r, deleteDecimal
  r[] = mpd_qnew()
  r.setDcml(a)

  if iScale > 0 :
    
    for i in 1..iScale :
      r*10
    mpd_qround_to_intx(r[], r[], CTX_CTRL, addr status)
    for i in 1..iScale :
      r/10

  else:
    r.floor(r)

  mpd_copy_data(a[],r[],addr status)



#@@@@@@@@@@@@@@@@@@
#----------------------------------------------------
# BORNAGE POUR LA GESTION compta : stock etc....
# arrivé decimal SQL  frmStr 
#----------------------------------------------------



proc newDcml*( iEntier: uint8 ; iScale : uint8 ): DecimalType =
  ## Initialize a empty DecimalType

  if iEntier + iScale  > cMaxDigit or ( iEntier == 0 and iScale == 0 ):
    raise newException(DecimalError, fmt"Failed Init {iEntier},{iScale}")

  var i:int = parseInt(fmt"{cMaxDigit}")
  let success = mpd_qsetprec(CTX_ADDR, i)
  if success == 0:
    raise newException(DecimalError, fmt"Couldn't set precision {cMaxDigit} ")

  var r:DecimalType
  new r, deleteDecimal
  r[] = mpd_qnew()
  r.entier = iEntier
  r.scale  = iScale
  r.setDcml("0")
  return r


proc delDcml*(a: DecimalType) =
  mpd_del(a[])
#@@@@@@@@@@@@@@@@@@
